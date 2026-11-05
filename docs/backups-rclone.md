# Informe del proyecto: Sistema de backups automatizados en MEGA

## 1. Qué queríamos hacer y qué montamos al final
Al principio, la idea de nuestro equipo era meter TrueNAS SCALE en una máquina virtual. Sin embargo, como el servidor entero solo tiene **8 GB de RAM**, nos dimos cuenta de que meter Proxmox y TrueNAS juntos iba a hacer que el sistema se congelara y se apagara por falta de memoria (TrueNAS es un devorador de RAM).

Para solucionarlo y no desperdiciar recursos, optamos por la mejor alternativa: **creamos un contenedor LXC con Debian** dedicado exclusivamente a gestionar las copias con **Rclone**. Este contenedor lo dejamos aislado del Proxmox principal, no ensucia el sistema base y consume **menos de 50 MB de RAM**, por lo que conseguimos que el servidor vaya totalmente sobrado.

---

## 2. Cómo funciona nuestro diseño
1. **El empaquetado:** Proxmox (programado desde la interfaz web) junta nuestras 2 VMs y nuestros 2 LXCs, los comprime en archivos súper ligeros `.zst` y los guarda en su carpeta local.
2. **El puente:** Conectamos la carpeta de backups de Proxmox (`/var/lib/vz/dump`) directamente con nuestro contenedor en la ruta `/backups` usando el comando `pct set`. Así logramos que el contenedor lea los archivos directamente sin tener que duplicar espacio.
3. **La subida:** El contenedor ejecuta `rclone` de madrugada, se conecta a internet y sube un espejo exacto de los archivos a nuestra cuenta de MEGA.

---

## 3. Fallos que nos dieron en la terminal y cómo los arreglamos

Durante la configuración en el contenedor `linksightBKP` nos surgieron unos cuantos errores típicos de la instalación, pero los fuimos cazando uno a uno en equipo:

*   **Faltaba el descompresor:** El script oficial de Rclone se descarga en un archivo `.zip`. Como nuestro contenedor Debian viene totalmente limpio de fábrica, descubrimos que no tenía cómo abrirlo y nos saltó el aviso de que faltaba `unzip` o `7z`. Lo solucionamos instalando el descompresor nativo con: `apt install unzip -y`.
*   **No aparecía MEGA en la lista:** Al hacer `rclone config`, MEGA no nos salía por ningún lado (ni escribiéndolo ni buscándolo). El problema era que la versión de Rclone que viene en los repositorios de Debian (`apt install`) es viejísima y viene recortada por temas de licencias. Tuvimos que borrarla (`apt purge`) e instalar la versión oficial desde el script de Rclone, que ya viene con el soporte de MEGA completo.
*   **Error "didn't find section in config file":** Al hacer la prueba de subida nos dio un error crítico diciendo que no encontraba la sección `mega_nube`. Fue simplemente un fallo al escribir el nombre del remoto en el asistente. Lo revisamos con `rclone listremotes` para ver cómo se había guardado y pudimos lanzar el comando bien.

---

## 4. Qué pasa con el Router y las reglas IPTABLES
Nuestro contenedor router (`linksightCT`) tiene las cadenas `INPUT` y `FORWARD` en **`DROP` por defecto** (bloquea todo lo que no conozca). 

**¿Por qué nos funciona el backup sin tener que volvernos locos con las reglas?**  
Porque el tráfico de Rclone hacia MEGA es de **salida** (puerto 443 HTTPS). Como nuestro router tiene configurado **NAT**, cuando nuestro contenedor de backups inicia la conexión para subir los archivos, el router la deja salir, traduce la IP interna y permite que MEGA le responda usando la tabla de estados de conexión (`RELATED,ESTABLISHED`). Al no ser tráfico que entra desde fuera hacia nuestra red, comprobamos que no hace falta abrir puertos ni tocar el firewall.

---

## 5. Cuándo se hacen las copias y cuánto espacio ocupan
Como el servidor solo lo usamos para clase los **miércoles y jueves**, programamos las tareas para que se hagan de madrugada esos días y el viernes, cubriendo cualquier posible pérdida de datos durante la semana:

*   **En la web de Proxmox:** Programamos el backup automático para los **miércoles, jueves y viernes a las 02:00 AM**.
*   **En la terminal del contenedor (Crontab):** Dejamos configurado Rclone para que recoja los archivos y los suba a MEGA los **miércoles, jueves y viernes a las 03:00 AM** con esta línea:
    ```text
    0 3 * * 3,4,5 rclone sync /backups/ mega_nube:CopiasProxmox
    ```

**El espacio en MEGA:** Al usar el comando `rclone sync`, el programa hace un espejo exacto. El jueves machaca lo del miércoles y el viernes lo del jueves. Nuestros backups completos del servidor comprimidos van a pesar entre **7 GB y 11 GB**, por lo que **nunca vamos a llenar los 20 GB gratis** de MEGA porque los archivos viejos se van sustituyendo por los nuevos.

Nuestra primera prueba manual funcionó perfecta y ya subió **439 MB** a la cuenta, lo que nos demuestra que el puente, el router y la cuenta de MEGA están perfectamente sincronizados y listos.
