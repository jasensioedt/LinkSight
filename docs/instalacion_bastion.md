
# Despliegue del Bastión

## Objetivo

El servidor bastión constituye el punto de acceso administrativo de la infraestructura de LinkSight. Su función es centralizar el acceso al sistema y servir como entorno seguro desde el que se gestionará y ejecutará la plataforma.

El bastión se despliega como una máquina virtual sobre Proxmox y será el único sistema expuesto para tareas de administración.

---

## Entorno de despliegue

### Hipervisor

- Proxmox VE

### Máquina virtual

- Nombre: `linksight`
- Sistema operativo: Alpine Linux
- CPU: 1 vCPU
- Memoria RAM: 2 GB
- Almacenamiento: 20 GB

---

## Instalación de Alpine Linux

La instalación se realizó utilizando la imagen **Alpine Linux Standard**.

Tras arrancar la máquina virtual desde la ISO, se ejecutó el asistente de configuración:

```sh
setup-alpine
```

Durante la instalación se utilizaron los siguientes parámetros:

```text
Keyboard Layout : es
Hostname        : linksight
Network         : DHCP
Timezone        : Europe/Madrid
APK Mirror      : Fastest Mirror
SSH Server      : OpenSSH
Disk            : /dev/sda
Installation    : sys
```

La opción `sys` instala Alpine Linux directamente en el disco, creando una instalación persistente apta para servidores.

Una vez completada la instalación, se verificó la correcta creación de las particiones:

```text
/dev/sda1  300 MB   Boot
/dev/sda2  493 MB   Swap
/dev/sda3  18,5 GB  Sistema principal
```

Finalizada la instalación, se apagó la máquina virtual, se desmontó la imagen ISO desde Proxmox y se configuró el arranque desde el disco virtual.

---

## Actualización del sistema

Después del primer arranque se actualizó el sistema mediante los repositorios oficiales de Alpine Linux:

```sh
apk update
apk upgrade
```

Con ello se instalaron las versiones más recientes disponibles para todos los paquetes del sistema.

---

## Instalación de paquetes básicos

A continuación se instalaron las herramientas necesarias para la administración inicial del servidor y la futura ejecución de LinkSight:

```sh
apk add nano sudo git curl python3 py3-pip openssh iptables
```

### Función de los paquetes instalados
<br>

- **nano**: editor de texto utilizado para modificar archivos de configuración.
- **sudo**: permite ejecutar comandos con privilegios administrativos.
- **git**: gestión y descarga de repositorios.
- **curl**: realización de peticiones HTTP desde la terminal.
- **python3**: entorno de ejecución principal de LinkSight.
- **py3-pip**: gestor de paquetes de Python.
- **openssh**: acceso remoto seguro mediante SSH.
- **iptables**: configuración de reglas de filtrado y control de tráfico de red.

<br>
---

## Creación del usuario administrativo

Una vez terminada la instalación se creó un usuario administrativo para evitar utilizar la cuenta `root` durante el trabajo diario.

```sh
adduser joel
```

Después se añadió el usuario al grupo `wheel` para poder ejecutar tareas administrativas mediante `sudo`:

```sh
addgroup joel wheel
```

También se configuró `sudo` para permitir la elevación de privilegios cuando fuese necesario.

---

## Configuración del acceso SSH

Para poder administrar el servidor de forma remota se configuró OpenSSH.

Primero se generó un par de claves SSH en el equipo cliente mediante el algoritmo Ed25519:

```powershell
ssh-keygen -t ed25519 -f D:\JoelSSH\id_ed25519
```

La clave pública generada se añadió al servidor dentro del fichero:

```text
~/.ssh/authorized_keys
```

Después se aplicaron los permisos necesarios:

```sh
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

Finalmente se comprobó el acceso remoto mediante SSH utilizando la clave privada generada.

En este punto ya es posible administrar el bastión de forma remota utilizando el usuario `joel` sin necesidad de introducir una contraseña.

---


## Estado actual del despliegue

Hasta este punto se ha completado:

- Instalación de Alpine Linux.
- Configuración inicial de red mediante DHCP.
- Instalación del servidor OpenSSH.
- Instalación de Python 3 y pip.
- Instalación de Git.
- Instalación de iptables.
- Preparación del entorno base para el despliegue de LinkSight.

---

## Próximos pasos

En las siguientes fases del proyecto se realizará:

- Creación del usuario administrativo.
- Configuración de acceso SSH mediante clave pública.
- Deshabilitación del acceso remoto del usuario root.
- Configuración del firewall con iptables.
- Implementación de auditoría del sistema.
- Despliegue de Nuclei.
- Integración de Ollama para el análisis de hallazgos.
- Instalación y configuración de los componentes de LinkSight.
