# Arquitectura del Software – LinkSight


**Objetivos**

Planificación del proyecto.

Definir una calendarización detallada con:

- objetivos

- resultados a alcanzar

- requisitos técnicos tanto hardware como de software

## **El por qué del diseño y la arquitectura de software**

La fase de planificación y diseño de la arquitectura es el cimiento sobre el cual se construye cualquier producto de software exitoso. Antes de escribir la primera línea de código o desplegar un servidor, es fundamental tener un plano, una estructura clara de lo que se va a construir.

Definir la arquitectura del software y la topología de red nos permite:

- **Mitigar riesgos**: Identificar cuellos de botella técnicos y problemas de seguridad antes de que ocurran.

- **Garantizar la escalabilidad y mantenibilidad**: Un sistema bien estructurado y modularizado (como el modelo cliente-servidor) es más fácil de actualizar y escalar en el futuro.

- **Optimizar recursos**: Conocer exactamente qué hardware, software y servicios se necesitan evita el desperdicio de tiempo y capacidad de cómputo.

- **Facilitar el trabajo en equipo**: Una documentación clara (diagramas E-R, requisitos, mapa de red) asegura que todas las partes involucradas entiendan el objetivo común.

- Saltarse esta fase suele derivar en: deuda técnica, vulnerabilidades de seguridad, sistemas frágiles.

Esta actividad está diseñada para que actúes como un Arquitecto de Software y Administrador de Sistemas, definiendo cada engranaje de tu proyecto.

**Planificación del proyecto y funcionalidades**

**Objetivos**

Definir una calendarización detallada de tu proyecto, estableciendo resultados a alcanzar y requisitos técnicos (tanto de hardware como de software).

**Instrucciones**

Siguiendo la plantilla a continuación, completa la matriz de requisitos y funcionalidades asignando una prioridad a cada función y una fecha aproximada de entrega. Sé lo más concreto posible.

| **ID** | **Prioridad** | **Objetivo**                                         | **Funcionalidad**                                                                                                                                                               | **Disparador**                                                | **Fecha Entrega** | **Estado** |
|--------|---------------|------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------|-------------------|------------|
| ID0    | Media         | Registrar usuarios en la plataforma                  | Formulario de registro (nombre, apellidos, email, contraseña) con validación en servidor y contraseña almacenada con hash. Rol de usuario asignado por defecto. | Botón «Crear cuenta» en la esquina superior derecha de la web | 05/11/2026        | Pendiente  |
| ID1    | Alta          | Acceder de forma segura a la aplicación              | Inicio de sesión con email y contraseña, sesión con cookie HttpOnly/Secure, bloqueo temporal tras intentos fallidos y segundo factor opcional (TOTP).                           | Botón «Iniciar sesión» en la esquina superior derecha         | 12/11/2026        | Pendiente  |
| ID2    | Media         | Gestionar el perfil de usuario                       | Página /perfil para ver y editar datos personales, cambiar contraseña, activar 2FA y ver las sesiones activas.                                                                  | Clic en el avatar de la esquina superior derecha              | 19/11/2026        | Pendiente  |
| ID3    | Baja          | Elegir el idioma de la interfaz                      | Selector de idioma (castellano/catalán/inglés) que guarda la preferencia en el perfil.                                                                                          | Menú de idioma en la cabecera                                 | 10/12/2026        | Pendiente  |
| ID4    | Alta          | Lanzar un análisis de vulnerabilidades sobre una web | Formulario con la URL objetivo y el tipo de análisis (estático, dinámico o completo). Se valida la URL y se crea un análisis en estado «pendiente» que se envía al bastión.     | Botón «Nuevo análisis» en el menú lateral                     | 26/11/2026        | Pendiente  |
| ID5    | Alta          | Garantizar que solo se analizan webs autorizadas     | El usuario debe declarar que es propietario o tiene permiso del objetivo; se registra la confirmación y se bloquean rangos internos y dominios no permitidos.                   | Envío del formulario de nuevo análisis                        | 26/11/2026        | Pendiente  |
| ID6    | Alta          | Detectar fallos en el código fuente (SAST)           | Análisis estático de ficheros subidos o repositorio: inyección SQL, XSS, secretos expuestos y funciones inseguras, indicando archivo y línea.                                   | Análisis de tipo estático o completo                          | 03/12/2026        | Pendiente  |
| ID7    | Alta          | Probar la web en ejecución (DAST)                    | Fuzzing y pruebas dinámicas desde el bastión en la DMZ contra la URL objetivo, sin exponer la red interna.                                                                      | Análisis de tipo dinámico o completo                          | 10/12/2026        | Pendiente  |
| ID8    | Media         | Revisar dependencias vulnerables                     | Lectura de manifiestos (requirements.txt, package.json) y consulta a OSV.dev y NVD para obtener CVE y puntuación CVSS.                                                          | Ejecución de cualquier análisis                               | 17/12/2026        | Pendiente  |
| ID9    | Media         | Entender y corregir cada hallazgo                    | La IA valida los falsos positivos y genera una explicación en lenguaje claro con una propuesta de corrección.                                                                   | Apertura de un hallazgo en el informe                         | 14/01/2027        | Pendiente  |
| ID10   | Alta          | Consultar los resultados de un análisis              | Informe con hallazgos ordenados por severidad (crítica, alta, media, baja), filtros y detalle por hallazgo.                                                                     | Fin del análisis o clic en una fila del historial             | 17/12/2026        | Pendiente  |
| ID11   | Media         | Conservar el historial de análisis                   | Listado paginado de análisis anteriores por usuario con estado, fecha y objetivo.                                                                                               | Opción «Historial» del menú lateral                           | 07/01/2027        | Pendiente  |
| ID12   | Media         | Descargar informes                                   | Exportación del informe en PDF y Markdown almacenada en el servidor.                                                                                                            | Botón «Descargar informe»                                     | 21/01/2027        | Pendiente  |
| ID13   | Baja          | Ver un panel resumen                                 | Dashboard con contadores de análisis, hallazgos por severidad y últimas actividades.                                                                                            | Carga de la página principal tras iniciar sesión              | 28/01/2027        | Pendiente  |
| ID14   | Alta          | Proteger los datos y recuperarlos ante fallos        | Copias de seguridad diarias cifradas de la base de datos y el código en una VM aparte, con prueba de restauración.                                                 | Tarea programada (cron) diaria a las 03:00                    | 04/02/2027        | Pendiente  |
| ID15   | Media         | Administrar usuarios y roles                         | Panel de administración para activar/desactivar cuentas y asignar roles (usuario, administrador).                                                                               | Opción «Administración» visible solo a administradores        | 11/02/2027        | Pendiente  |

**Arquitectura del sistema**

Uno de los fundamentos de la arquitectura es la identificación de componentes: determinar las piezas clave o módulos que compondrán una aplicación web. Cada componente realiza funciones específicas y se integra con otros para lograr el conjunto completo de características.

La arquitectura obligatoriamente será cliente-servidor. Identifica el software, la versión a utilizar, los puertos de funcionamiento, el dominio (si lo requiere) y justifica brevemente tu elección tecnológica.

Identifica el software, la versión a utilizar, el puerto de funcionamiento y el dominio si así lo requiera y explica brevemente para que se va a utilizar esa tecnología.

| **Componente de sistema**           | **Tecnología o framework (elige de la lista o añade el que vayas a utilizar)**       | **Versión**                | **Puerto**               | **Descripción de uso o requisitos**                                                                        | **Enlace a documentación o información adicional** |
|-------------------------------------|--------------------------------------------------------------------------------------|----------------------------|--------------------------|------------------------------------------------------------------------------------------------------------|----------------------------------------------------|
| **Hardware**                        | Servidor físico del aula (x86-64, virtualización VT-x), 16 GB RAM mínimo, 500 GB SSD | —                          | no                       | Aloja el hipervisor y todas las VM de LinkSight (web, BD, DNS/DHCP, copias, bastión, cliente).             | https://pve.proxmox.com/wiki/System_Requirements   |
| **Sistema operativo**               | Debian GNU/Linux (libre) en todas las VM; hipervisor Proxmox VE                      | Debian 13 / Proxmox VE 8.x | no                       | Sistema libre, estable y mínimo; el bastión usa instalación minimal para reducir superficie de ataque.     | https://www.debian.org/doc/                        |
| **Interfaz de usuario (Frontend)**  | HTML5, CSS3, JavaScript, Bootstrap                                                   | Bootstrap 5.3              | 443 (HTTPS)              | Web responsive: landing, login, registro, dashboard, nuevo análisis, historial, informe, ajustes y perfil. | https://getbootstrap.com/docs/5.3/                 |
| **Servidor web**                    | Nginx como proxy inverso con TLS                                                     | Nginx 1.26                 | 443 / 80 (redirige)      | Termina HTTPS en linksight.lan y reenvía a Gunicorn; cabeceras de seguridad.                               | https://nginx.org/en/docs/                         |
| **Base de datos** | MariaDB | MariaDB 11.8 LTS | 3306 (solo desde VM-WEB) | Almacena usuarios, análisis, hallazgos, dependencias e informes. | https://mariadb.com/kb/en/documentation/ |
| **Sistema gestor de base de datos** | DBeaver / cliente mariadb por SSH | DBeaver 24 | 3306 vía túnel SSH | Administración y consultas del esquema desde el PC del administrador. | https://dbeaver.com/docs/ |
| **DNS**                             | BIND9                                                                                | BIND 9.20                  | 53 (TCP/UDP)             | Resuelve linksight.lan en la red interna (VM-DNS-DHCP 192.168.50.2).                                       | https://bind9.readthedocs.io/                      |
| **DHCP**                            | Kea DHCP                                                                             | Kea 2.6                    | 67 (UDP)                 | Reparte IP dinámicas .100–.200 al cliente y reserva las IP estáticas de los servidores.                    | https://kea.readthedocs.io/                        |
| **Copias de seguridad**             | BorgBackup sobre SSH + mysqldump                                                     | Borg 1.4                   | 22 (SSH)                 | Copias diarias cifradas y deduplicadas de BD y código en VM-BACKUP (192.168.50.30).                        | https://borgbackup.readthedocs.io/                 |
| **Bastión de análisis (DMZ)**       | Debian minimal, OpenSSH, fail2ban, auditd                                            | OpenSSH 10.0               | 22 (solo desde .50.10)   | Ejecuta los análisis contra webs objetivo aislado en la DMZ 192.168.60.0/24.                               | https://www.openssh.com/manual.html                |
| **Cortafuegos** | iptables (netfilter) con iptables-persistent, en un contenedor LXC | iptables 1.8 | — | Contenedor LXC en el servidor Proxmox que hace de router con iptables: MASQUERADE para dar salida a internet a las redes internas y DNAT 443. Política por defecto DROP en INPUT y FORWARD. En cada VM solo se abren los puertos necesarios. Reglas guardadas con netfilter-persistent. | https://www.netfilter.org/projects/iptables/ |

**Diagrama de la Base de Datos**

Tal y como hemos visto en la actividad de bases de datos, utilizamos diagramas Entidad-Relación (E-R) para planificar visualmente las tablas, campos, tipos de datos, relaciones (1:1, 1:N, N:M) y claves (Primary y Foreign Keys).

**Instrucciones**

- Adjunta el diagrama E-R de tu aplicación web. Para construirlo, reflexiona sobre lo siguiente:

<!-- -->

- ¿Qué datos son estrictamente necesarios para el funcionamiento de mi aplicación?

- ¿Qué tipos de usuarios/roles voy a tener y qué datos recopilaré de ellos?

- ¿Qué tipo de dato es el óptimo para cada campo? (Consulta la documentación oficial de MySQL).

- ¿Están mis tablas normalizadas? ¿Están bien gestionadas las relaciones de cardinalidad N:M con tablas intermedias?

![Diagrama E-R](er.png)

*Figura 1. Diagrama Entidad-Relación de LinkSight (MySQL 8.4).*

Normalización: el esquema cumple 3FN; cada tabla depende solo de su clave primaria y no hay datos repetidos (roles y módulos tienen su propia tabla).

Roles: la tabla roles (usuario, administrador) se relaciona 1:N con usuarios; el rol decide qué opciones ve cada persona.

Cardinalidad N:M: un análisis puede ejecutar varios módulos (SAST, DAST, dependencias) y un módulo se usa en muchos análisis, resuelto con la tabla puente analisis_modulos.

Datos y seguridad: contraseñas solo como password_hash, secreto TOTP, URL en VARCHAR(2048), severidad y estado como ENUM, claves foráneas con índices y consultas parametrizadas desde Flask para evitar inyección SQL.

Nota: Puedes usar herramientas gráficas gratuitas como Draw.io, Microsoft Visio, Lucidchart o MySQL Workbench.

### **Desarrollo y Base de Datos**

- Diseño UI/UX: Crear un mapa de navegabilidad y bocetos (wireframes) de las pantallas. Definir los roles de usuario y explicar qué hace cada elemento de la interfaz.

- Desarrollo Web: Programar la web (Frontend responsive usando Bootstrap o CSS custom) y conectar la lógica de Backend con la Base de Datos.

- Calidad de la BD: Implementar el diseño E-R en la base de datos real. Usar tipos de datos correctos, límites de caracteres por seguridad, y tablas intermedias para relaciones N:N.

- Control de versiones: Usar Git y un repositorio en GitHub para llevar el control de versiones del código y albergar la documentación del proyecto.

**Infraestructura y preparación de las máquinas virtuales - Proxmox**

Para implementar la aplicación, deberás desplegar un entorno de red virtualizado que recree una arquitectura cliente-servidor robusta y segura.

A continuación, se detalla el Checklist de Requisitos Imprescindibles que tu proyecto debe cumplir:

**Topología y Red**

- Despliegue de VM: Crear un mínimo cuatro VM para servidores: 1. Base de Datos, 2. Servidor Web, 3. DNS + DHCP y 4. Copias de Seguridad.

- Cliente: Configurar una VM adicional (Cliente) que solicitará IP por DHCP para conectar a la web.

- Servicios de Red: El servidor DHCP debe asignar un rango protegido (IPs estáticas reservadas para servidores, rango dinámico para clientes). El DNS debe resolver el dominio propio (ejemplo: tudominio.com) hacia las IPs correspondientes.

- Routing/NAT: Configurar reenvío de puertos (Port Forwarding) desde el Gateway virtual al puerto web del servidor en la red NAT.

- Documentación: Presentar un Diagrama de Red detallado, diferenciando claramente los elementos físicos reales y los virtuales (IPs, subredes, interfaces).

![Diagrama de red](net.png)

*Figura 2. Diagrama de red: elementos físicos (gris) y virtuales (color) en Proxmox VE.*

| **Máquina**                  | **IP**                      | **Servicios / puertos**                        | **Red**               |
|------------------------------|-----------------------------|------------------------------------------------|-----------------------|
| Gateway / NAT (host Proxmox) | 192.168.50.1 · 192.168.60.1 | DNAT 443 → .50.10:443, UFW                     | vmbr0 / vmbr1 / vmbr2 |
| VM-DNS-DHCP                  | 192.168.50.2                | BIND9 53 · Kea 67/udp                          | LAN                   |
| VM-WEB                       | 192.168.50.10               | Nginx 443 · Gunicorn 8000                      | LAN                   |
| VM-BD                        | 192.168.50.20               | MySQL 3306 (solo desde .10)                    | LAN                   |
| VM-BACKUP                    | 192.168.50.30               | BorgBackup · SSH 22                            | LAN                   |
| VM-CLIENTE                   | DHCP .100–.200              | Navegador → https://linksight.lan              | LAN                   |
| VM-BASTIÓN                   | 192.168.60.10               | SSH 22 (solo desde .50.10) · fail2ban · auditd | DMZ                   |

### 

### **Seguridad**

- **Firewall**: Implementar y configurar un cortafuegos (UFW o IPTABLES). Aplicar el principio de mínimo privilegio (Ej: La base de datos solo debe aceptar conexiones entrantes desde la IP del Servidor Web, bloqueando el resto).

- **Conexión segura**: Implementación de métodos de seguridad para el acceso al servidor (ej. SSH con claves) y protección en los scripts de llamada a la base de datos (prevención de inyecciones SQL, credenciales ocultas).

• Reglas UFW: política por defecto «denegar entrada»; VM-WEB abre 443; VM-BD acepta 3306 solo desde 192.168.50.10; el bastión acepta SSH solo desde 192.168.50.10.

• Acceso por SSH con clave pública (PasswordAuthentication no, PermitRootLogin no), fail2ban y auditd en el bastión.

• Aplicación: HTTPS obligatorio, contraseñas con hash, consultas parametrizadas y copias de seguridad cifradas.

## **Evaluación**

La evaluación de esta fase se realizará de forma presencial en el aula. Se requerirá una demostración funcional de un "Hello world" operativo bajo la infraestructura diseñada.

| 2p   | Satisfactorio   | Desde el navegador de una máquina de la red real se puede acceder mediante dominio personalizado a la web de prueba. |
|------|-----------------|----------------------------------------------------------------------------------------------------------------------|
| 1,5p | Bien            | Desde el navegador de una máquina virtual se puede acceder mediante dominio personalizado a la web de prueba.        |
| 1p   | Necesita mejora | Desde el navegador de la máquina virtual se puede acceder a la web de prueba mediante dominio localhost.             |
| 0p   | Insatisfactorio | No se cumple ningún requisito anteriormente mencionado o no se ha realizado a tiempo.                                |
