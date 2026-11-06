# Envío de logs de Proxmox a Discord

## 1. Objetivo

Recibir en Discord, en tiempo real, cada línea nueva que se añade a dos archivos de log de Proxmox (por ejemplo, los generados por los scripts de backup). Cada archivo se envía a un canal distinto mediante su propio webhook.

## 2. Resumen de la solución

| Elemento | Decisión |
|---|---|
| Plataforma de mensajería | Discord (webhooks, sin necesidad de crear un bot) |
| Lectura del log | `tail -Fn0` (solo líneas nuevas, sigue el archivo si se rota) |
| Envío | `curl` + `jq` contra la API del webhook |
| Ejecución permanente | Servicio systemd (alternativa: crontab con `flock`) |
| Organización | 1 webhook + 1 script + 1 servicio por archivo de log |

## 3. Alternativas valoradas

- **Telegram (BotFather)**: requiere crear un bot, obtener el token y el `chat_id`. Se envía a `https://api.telegram.org/bot<TOKEN>/sendMessage`.
- **Slack**: Incoming Webhooks, igual que Discord con el JSON `{"text": "..."}`.
- **ntfy.sh / Gotify**: notificaciones push sin cuentas ni bots, también autoalojables.
- **Email**: con `msmtp` o `mailx`, más pesado de configurar.

Se eligió Discord por la sencillez de los webhooks y por permitir separar cada log en su propio canal.

## 4. Crear los webhooks en Discord

1. Crear un canal por cada log.
2. En cada canal: **Ajustes del canal → Integraciones → Webhooks → Nuevo webhook**.
3. Copiar la **URL del webhook** de cada uno.

> Los webhooks funcionan como contraseñas: quien tenga la URL puede publicar en el canal. No compartirlos ni subirlos a repositorios públicos.

## 5. Instalación de dependencias

```bash
apt update && apt install -y curl jq
```

## 6. Scripts

### Log 1

```bash
nano /usr/local/bin/log2discord_1.sh
```

```bash
#!/bin/bash
WEBHOOK="https://discord.com/api/webhooks/ID_1/TOKEN_1"
LOGFILE="/var/log/backup_linksight.log"

tail -Fn0 "$LOGFILE" | while read -r line; do
  [ -z "$line" ] && continue
  curl -s -H "Content-Type: application/json" \
    -d "$(jq -n --arg c "$(hostname): ${line}" '{content: $c}')" \
    "$WEBHOOK" > /dev/null
  sleep 1
done
```

### Log 2

```bash
nano /usr/local/bin/log2discord_2.sh
```

```bash
#!/bin/bash
WEBHOOK="https://discord.com/api/webhooks/ID_2/TOKEN_2"
LOGFILE="/var/log/otro.log"

tail -Fn0 "$LOGFILE" | while read -r line; do
  [ -z "$line" ] && continue
  curl -s -H "Content-Type: application/json" \
    -d "$(jq -n --arg c "$(hostname): ${line}" '{content: $c}')" \
    "$WEBHOOK" > /dev/null
  sleep 1
done
```

### Permisos

```bash
chmod 700 /usr/local/bin/log2discord_1.sh /usr/local/bin/log2discord_2.sh
```

### Explicación del script

- `tail -F`: sigue el archivo por nombre, aunque se rote o se recree.
- `-n0`: no muestra las líneas existentes; solo se envían las que se añaden a partir de que arranca el script. Para enviar también las últimas N líneas al arrancar, cambiar el `0` por ese número (por ejemplo `-Fn10`).
- `[ -z "$line" ] && continue`: ignora líneas vacías.
- `jq -n --arg`: construye el JSON escapando correctamente comillas y caracteres especiales.
- `hostname`: antepone el nombre del servidor al mensaje.
- `sleep 1`: evita superar el límite de velocidad de la API.
- Límite de Discord: 2000 caracteres por mensaje.

## 7. Servicios systemd (método elegido)

### Por qué systemd

El script con `tail -F` se ejecuta indefinidamente. Con systemd se obtiene:

- Arranque automático al iniciar el servidor.
- Reinicio automático si el script falla (`Restart=always`).
- Ejecución en segundo plano, sin depender de una sesión SSH.
- Gestión con `systemctl` y consulta de logs con `journalctl`.

### Servicio 1

```bash
nano /etc/systemd/system/log2discord_1.service
```

```ini
[Unit]
Description=Enviar log 1 a Discord
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/log2discord_1.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### Servicio 2

```bash
nano /etc/systemd/system/log2discord_2.service
```

```ini
[Unit]
Description=Enviar log 2 a Discord
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/local/bin/log2discord_2.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### Activación

```bash
systemctl daemon-reload
systemctl enable --now log2discord_1.service log2discord_2.service
systemctl status log2discord_1.service log2discord_2.service
```

## 8. Alternativa con crontab

### Solo al arrancar

```bash
crontab -e
```

```cron
@reboot /usr/local/bin/log2discord_1.sh >/dev/null 2>&1
@reboot /usr/local/bin/log2discord_2.sh >/dev/null 2>&1
```

### Al arrancar y relanzando si se cae

```cron
* * * * * flock -n /tmp/log2discord_1.lock /usr/local/bin/log2discord_1.sh >/dev/null 2>&1
* * * * * flock -n /tmp/log2discord_2.lock /usr/local/bin/log2discord_2.sh >/dev/null 2>&1
```

`flock -n` impide lanzar una segunda instancia si ya hay una en ejecución.

### Comprobar que está corriendo

```bash
pgrep -af log2discord
```

### Diferencias respecto a systemd

| | systemd | crontab |
|---|---|---|
| Reinicio tras caída | ~5 segundos | hasta 1 minuto |
| Estado y logs | `systemctl status`, `journalctl` | no disponible |
| Complejidad | Media | Baja |

## 9. Pruebas

```bash
echo "prueba 1" >> /var/log/backup_linksight.log
echo "prueba 2" >> /var/log/otro.log
```

Cada mensaje debe aparecer en su canal de Discord en aproximadamente un segundo.

Para que los scripts propios de backup envíen sus logs, deben escribir añadiendo al archivo vigilado:

```bash
echo "$(date) backup terminado" >> /var/log/backup_linksight.log
```

Si un script solo imprime por pantalla y no escribe en el archivo, no se enviará nada.

## 10. Comandos de gestión

```bash
systemctl status log2discord_1
systemctl restart log2discord_1
systemctl stop log2discord_1
journalctl -u log2discord_1 -f
```

## 11. Notas y limitaciones

- Solo se envían las líneas añadidas después de arrancar el servicio.
- Si un log genera muchas líneas de golpe, los mensajes se irán enviando de uno en uno por el `sleep 1`.
- Si se usan varios archivos con un único `tail`, este inserta cabeceras `==> archivo <==` que también se enviarían; por eso se usa un script por archivo.
- Discord limita los mensajes a 2000 caracteres; las líneas más largas fallarían.
- Sustituir `/var/log/otro.log` por la ruta real del segundo log.
