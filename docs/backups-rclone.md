# Informe del proyecto: Sistema de backups automatizados en MEGA

## 1. Qué queríamos hacer y qué montamos al final
Al principio, la idea era meter TrueNAS SCALE en una máquina virtual. Sin embargo, como el servidor entero solo tiene **8 GB de RAM**, nos dimos cuenta de que meter Proxmox y TrueNAS juntos iba a hacer que el sistema se congelara y se apagara por falta de memoria (TrueNAS es un devorador de RAM).

Para solucionarlo y no desperdiciar recursos, optamos por la mejor alternativa: **creamos un contenedor LXC con Debian** dedicado exclusivamente a gestionar las copias con **Rclone**. Este contenedor lo dejamos aislado del Proxmox principal, no ensucia el sistema base y consume **menos de 50 MB de RAM**, por lo que conseguimos que el servidor no se sature.

---

## 2. Cómo funciona nuestro diseño
1. **El empaquetado:** Proxmox (programado desde la interfaz web) junta nuestras máquinas, las comprime en archivos súper ligeros `.zst` y los guarda en su carpeta local.
2. **El puente:** Conectamos la carpeta de backups de Proxmox (`/var/lib/vz/dump`) directamente con nuestro contenedor en la ruta `/backups_completo` usando el comando `pct set`. Así logramos que el contenedor lea los archivos directamente sin tener que duplicar espacio.
3. **La subida:** El contenedor ejecuta `rclone` de madrugada, se conecta a internet y sube un espejo exacto de los archivos a nuestra cuenta de MEGA. Las copias completas de las máquinas se suben los lunes.
4. **La copia de datos:** Además de las máquinas enteras, el contenedor `linksightBKP` hace cada noche una copia de los **datos**: un volcado de todas las bases de datos (servidor `10.10.10.3`) y una copia de la web (servidor `10.10.10.2`, carpeta `/var/www/html`). Esta copia ocupa muy poco y se sube a MEGA.

---

## 3. Fallos que nos dieron en la terminal y cómo los arreglamos

Durante la configuración en el contenedor `linksightBKP` nos surgieron unos cuantos errores típicos de la instalación:

*   **Faltaba el descompresor:** El script oficial de Rclone se descarga en un archivo `.zip`. Como nuestro contenedor Debian viene totalmente limpio de fábrica, descubrimos que no tenía cómo abrirlo y nos saltó el aviso de que faltaba `unzip` o `7z`. Lo solucionamos instalando el descompresor nativo con: `apt install unzip -y`.
*   **No aparecía MEGA en la lista:** Al hacer `rclone config`, MEGA no nos salía por ningún lado (ni escribiéndolo ni buscándolo). El problema era que la versión de Rclone que viene en los repositorios de Debian (`apt install`) es vieja y viene recortada por temas de licencias. Tuvimos que borrarla (`apt purge`) e instalar la versión oficial desde el script de Rclone, que ya viene con el soporte de MEGA completo.
*   **`rsync: orden no encontrada`:** Al traer los archivos de la web con `rsync`, el error venía del servidor web (`10.10.10.2`), que no tenía `rsync` instalado. Lo solucionamos instalándolo ahí con `apt update && apt install -y rsync`.
*   **`mysqldump: Access denied for user 'root'`:** El servidor de base de datos no permite que `root` se conecte desde otra IP. En lugar de abrir `root`, creamos un usuario `backup` con permisos solo de lectura, limitado a la IP del contenedor de backups:
    ```sql
    CREATE USER 'backup'@'10.10.10.10' IDENTIFIED BY 'CONTRASEÑA';
    GRANT SELECT, SHOW VIEW, TRIGGER, LOCK TABLES, EVENT, PROCESS ON *.* TO 'backup'@'10.10.10.10';
    FLUSH PRIVILEGES;
    ```
    También comprobamos que el servidor escucha por red (`bind-address` en la configuración de MariaDB) y reiniciamos el servicio con `systemctl restart mariadb`.

---

## 4. Qué pasa con el Router y las reglas IPTABLES
Nuestro contenedor router (`linksightCT`) tiene las cadenas `INPUT` y `FORWARD` en **`DROP` por defecto** (bloquea todo lo que no conozca). 

**¿Por qué nos funciona el backup sin tener que volvernos locos con las reglas?**  
Porque el tráfico de Rclone hacia MEGA es de **salida** (puerto 443 HTTPS). Como nuestro router tiene configurado **NAT**, cuando nuestro contenedor de backups inicia la conexión para subir los archivos, el router la deja salir, traduce la IP interna y permite que MEGA le responda usando la tabla de estados de conexión (`RELATED,ESTABLISHED`). Al no ser tráfico que entra desde fuera hacia nuestra red, comprobamos que no hace falta abrir puertos ni tocar el firewall.

---

## 5. Copia diaria de datos (base de datos y web)

Desde el contenedor `linksightBKP` automatizamos la copia de los datos con un script, `/root/backups.sh`, que hace tres cosas seguidas:

1. **Volcado de las bases de datos por red** con `mysqldump` (todas las bases, sin bloquear tablas gracias a `--single-transaction`).
2. **Copia de la web** con `rsync` por SSH desde `10.10.10.2`.
3. **Subida a MEGA** con `rclone sync`, que deja la carpeta `CopiasProxmox` de MEGA como un espejo de la carpeta local `/root/backup_linksight/`.

```bash
#!/bin/bash
set -e

mkdir -p /root/backup_linksight/db /root/backup_linksight/web

mysqldump -h 10.10.10.3 -u backup -p'CONTRASEÑA' --all-databases --single-transaction --routines --events > /root/backup_linksight/db/todas_las_bases.sql

rsync -avz --delete root@10.10.10.2:/var/www/html/ /root/backup_linksight/web/

rclone sync /root/backup_linksight/ mega:CopiasProxmox
```

Detalles del script:

*   **`set -e`:** si algún paso falla, el script se detiene. Así, si el volcado de la base de datos falla, no se sube nada a MEGA y no se pisa la copia buena que ya había.
*   **Acceso sin contraseña:** para que `rsync` funcione desde cron, el contenedor entra por SSH al servidor web con clave (`ssh-keygen -t ed25519` y `ssh-copy-id root@10.10.10.2`).
*   **Permisos:** `chmod +x /root/backups.sh`.

Línea en el crontab del contenedor (`crontab -e`), todos los días a las 03:00 y guardando la salida en un log:

```text
0 3 * * * /root/backups.sh >> /var/log/backups.log 2>&1
```

---

## 6. Copia completa de las máquinas (subida semanal a MEGA)

Para tener también las **máquinas enteras** en MEGA, subimos los backups que genera Proxmox desde el puente con el contenedor, sin copiarlos antes a ningún sitio.

**Montar el puente.** En el **host de Proxmox** (el contenedor `linksightBKP` es el 104):

```bash
pct set 104 -mp0 /var/lib/vz/dump,mp=/backups_completo
pct reboot 104
```

El nombre de la ruta dentro del contenedor (`mp=`) se puede elegir; lo que no se cambia es `/var/lib/vz/dump`, que es donde Proxmox guarda los backups. Podemos comprobar que quedó bien con `pct config 104 | grep mp`.

**Comprobar que el contenedor ve los backups.** Dentro de `linksightBKP`:

```bash
ls -lh /backups_completo
```

Deben aparecer los archivos `vzdump-*` (el backup `.zst`, su `.log` y su `.notes`).

**Probar la subida antes de automatizarla.** Primero en simulación, para ver qué haría sin subir nada, y después de verdad:

```bash
rclone sync /backups_completo/ mega:CopiasCompletas --include "vzdump-*" --dry-run
rclone sync /backups_completo/ mega:CopiasCompletas --include "vzdump-*" --progress
rclone ls mega:CopiasCompletas
```

El filtro `--include "vzdump-*"` coincide también con los `.log` y `.notes`, así que los registros de cada backup también se suben a MEGA.

**Automatizarlo.** Línea en el crontab del contenedor, solo los **lunes a las 05:00**:

```text
0 5 * * 1 rclone sync /backups_completo/ mega:CopiasCompletas --include "vzdump-*" >> /var/log/subida_mega.log 2>&1
```

Se programa a las 05:00 para que Proxmox haya terminado de escribir los archivos antes de que Rclone empiece a subirlos.

---

## 7. Cuándo se hacen las copias y cuánto espacio ocupan
Programamos las tareas para que se hagan de madrugada: la copia de datos todos los días y la subida de las máquinas completas los lunes. Para que no coincidan entre sí, las dejamos escalonadas:

| Hora | Qué se hace | Dónde |
|------|-------------|-------|
| 02:00 cada dia | Backup de las máquinas "importantes" (Web/BD) a `/var/lib/vz/dump` | Interfaz web de Proxmox |
| 03:00 cada dia | Copia de datos (base de datos y web) a `CopiasProxmox` | Crontab del contenedor |
| 04:00 cada lunes | Backup de todas las máquinas a `/var/lib/vz/dump` | Interfaz web de Proxmox |
| 05:00 cada lunes | Subida de los backups de las máquinas a `CopiasCompletas` en MEGA | Crontab del contenedor |

**El espacio en MEGA:** Al usar el comando `rclone sync`, el programa hace un espejo exacto. Cada lunes la subida machaca lo de la semana anterior. Nuestros backups completos del servidor comprimidos van a pesar entre **7 GB y 11 GB**, por lo que **nunca vamos a llenar los 20 GB** de MEGA porque los archivos viejos se van sustituyendo por los nuevos. La copia de datos ocupa muy poco.

Nuestra primera prueba manual funcionó perfecta y ya subió **2,8MB** de archivos sql y web y **4,8GB** de copia completa, lo que nos demuestra que el puente, el router y la cuenta de MEGA están perfectamente sincronizados y listos.
