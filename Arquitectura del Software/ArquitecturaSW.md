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

| ID | Prioridad | Objetivo | Funcionalidad | Disparador | Fecha Entrega | Estado |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: |
| ID0 | Alta | Registrar usuarios en la plataforma | Sistema de registro con nombre, apellidos, correo electrónico y contraseña almacenada de forma segura mediante hash. | Botón de registro en la esquina superior derecha. | ... | Pendiente |
| ID1 | Alta | Iniciar sesión de forma segura | Inicio de sesión mediante correo y contraseña | Botón de inicio de sesión. | ...| Pendiente |
| ID2 | Media | Gestionar el perfil de usuario | Modificación de datos personales, cambio de contraseña y gestión de la cuenta. | Menú de perfil del usuario. | ... | Pendiente |
| ID3 | Baja | Seleccionar idioma de la interfaz | Permitir cambiar el idioma de la aplicación y guardar la preferencia del usuario. | Selector de idioma de la interfaz. | ... | Pendiente |
| ID4 | Alta | Crear un nuevo análisis | Permitir al usuario introducir una URL para iniciar un análisis de seguridad. | Botón «Nuevo análisis». | ... | Pendiente |
| ID5 | Alta | Verificar el uso autorizado de la herramienta | Confirmar que el usuario dispone de autorización para analizar el objetivo indicado. | Envío del formulario de nuevo análisis. | ... | Pendiente |
| ID6 | Alta | Ejecutar análisis mediante Nuclei | Integración con Nuclei para detectar vulnerabilidades, exposiciones de información y errores de configuración. | Inicio de un nuevo análisis. | ... | Pendiente |
| ID7 | Alta | Analizar hallazgos mediante IA | Procesar los resultados obtenidos por Nuclei utilizando Ollama para generar explicaciones y recomendaciones. | Finalización del análisis. | ... | Pendiente |
| ID8 | Alta | Consultar resultados de análisis | Mostrar vulnerabilidades detectadas ordenadas por severidad con filtros y búsqueda. | Acceso a un informe finalizado. | ... | Pendiente |
| ID9 | Media | Revisar el historial de análisis | Almacenar y consultar análisis anteriores realizados por cada usuario. | Menú «Historial». | ... | Pendiente |
| ID10 | Media | Descargar informes | Exportación de informes en formato PDF y Markdown. | Botón «Descargar informe». | ... | Pendiente |
| ID11 | Baja | Panel resumen | Dashboard con estadísticas de análisis realizados y distribución de vulnerabilidades por severidad. | Pantalla principal tras iniciar sesión. | ... | Pendiente |
| ID12 | Alta | Gestión de copias de seguridad | Copias de seguridad automáticas de la base de datos, informes y configuración. | Tarea programada diaria. | ... | Pendiente |
| ID13 | Media | Administración de usuarios | Gestión de cuentas y roles mediante un panel de administración. | Menú de administración. | ... | Pendiente |
| ID14 | Media | Gestión de vulnerabilidades detectadas | Mostrar información detallada del hallazgo, impacto, severidad y recomendación generada por IA. | Selección de una vulnerabilidad dentro de un informe. | ... | Pendiente |
| ID15 | Media | Monitorización de análisis | Mostrar el estado de ejecución de los análisis (Pendiente, En ejecución, Completado o Error). | Página de historial o detalle del análisis. | ... | Pendiente |
| ID16 | Baja | Auditoría de acciones | Registrar accesos, creación de análisis, descargas de informes y acciones administrativas. | Acciones realizadas por los usuarios. | ... | Pendiente |

**Arquitectura del sistema**

Uno de los fundamentos de la arquitectura es la identificación de componentes: determinar las piezas clave o módulos que compondrán una aplicación web. Cada componente realiza funciones específicas y se integra con otros para lograr el conjunto completo de características.

La arquitectura obligatoriamente será cliente-servidor. Identifica el software, la versión a utilizar, los puertos de funcionamiento, el dominio (si lo requiere) y justifica brevemente tu elección tecnológica.

Identifica el software, la versión a utilizar, el puerto de funcionamiento y el dominio si así lo requiera y explica brevemente para que se va a utilizar esa tecnología.

| **Componente de sistema**           | **Tecnología o framework (elige de la lista o añade el que vayas a utilizar)**       | **Versión**                | **Puerto**               | **Descripción de uso o requisitos**                                                                        | **Enlace a documentación o información adicional** |
|-------------------------------------|--------------------------------------------------------------------------------------|----------------------------|--------------------------|------------------------------------------------------------------------------------------------------------|----------------------------------------------------|
| **Hardware**                        | Servidor físico del aula (x86-64, virtualización VT-x), 8 GB RAM , 93 GB SSD | —                          | -                       | Aloja el hipervisor y todas las VM de LinkSight (web, BD, DNS/DHCP, copias, bastión, cliente).             | https://pve.proxmox.com/wiki/System_Requirements   |
| **Sistema operativo** | Debian/Alpine en todos los CT y VM; TrueNAS para las copias; hipervisor Proxmox VE | Debian 12 / Alpine Linux / TrueNAS 25.10 / Proxmox VE 8.x | - | Sistemas libres y ligeros. TrueNAS se usa para guardar las copias. | https://www.debian.org/doc/ |
| **Interfaz de usuario (Frontend)**  | HTML5, CSS3, JavaScript, Bootstrap                                                   | Bootstrap 5.3              | 443 (HTTPS)              | Web responsive: landing, login, registro, dashboard, nuevo análisis, historial, informe, ajustes y perfil. | https://getbootstrap.com/docs/5.3/                 |
| **Servidor web**                    | Nginx como proxy inverso con TLS                                                     | Nginx 1.26                 | 443 / 80 (redirige)      | Termina HTTPS en linksight.lan y reenvía a Gunicorn; cabeceras de seguridad.                               | https://nginx.org/en/docs/                         |
| **Base de datos** | MariaDB | MariaDB 11.8 LTS | 3306 | Guarda usuarios, análisis, hallazgos e informes. | https://mariadb.com/kb/en/documentation/ |
| **Sistema gestor de base de datos** | DBeaver / cliente mariadb por SSH | DBeaver 24 | 3306 vía túnel SSH | Administración y consultas del esquema desde el PC del administrador. | https://dbeaver.com/docs/ |
| **DNS**                             | BIND9                                                                                | BIND 9.20                  | 53 (TCP/UDP)             | Resuelve linksight.lan en la red interna (VM-DNS-DHCP 192.168.50.2).                                       | https://bind9.readthedocs.io/                      |
| **DHCP**                            | Kea DHCP                                                                             | Kea 2.6                    | 67 (UDP)                 | Reparte IP dinámicas .100–.200 al cliente y reserva las IP estáticas de los servidores.                    | https://kea.readthedocs.io/                        |
| **Copias de seguridad** | BorgBackup, con TrueNAS como destino | Borg 1.4 / TrueNAS 25.10 | 22 (SSH) / 2049 (NFS) | Copias diarias cifradas de la base de datos y el código en VM-BACKUP (192.168.50.30), guardadas en TrueNAS. | https://www.truenas.com/docs/ |
| **Bastión de análisis (DMZ)**       | Alpine, OpenSSH, fail2ban, auditd                                            | OpenSSH 10.0               | 22    | Ejecuta los análisis contra webs objetivo aislado en la DMZ 192.168.60.0/24.                               | https://www.openssh.com/manual.html                |
| **Cortafuegos** | iptables (netfilter) con iptables-persistent, en un contenedor LXC | iptables 1.8 | — | Contenedor LXC en el servidor Proxmox que hace de router con iptables: MASQUERADE para dar salida a internet a las redes internas y DNAT 443. Política por defecto DROP en INPUT y FORWARD. En cada VM solo se abren los puertos necesarios. Reglas guardadas con netfilter-persistent. | https://www.netfilter.org/projects/iptables/ |

**Diagrama de la Base de Datos**

Utilizamos diagramas Entidad-Relación (E-R) para planificar visualmente las tablas, campos, tipos de datos, relaciones (1:1, 1:N, N:M) y claves (Primary y Foreign Keys).

![Diagrama E-R](../img/diagrama_er.png)

*Figura 1. Diagrama Entidad-Relación de LinkSight*

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

**Arquitectura de red**

```text
                           ┌───────────────┐
                           │ Casa (NetBird)│
                           └───────┬───────┘
                                   │
                                   ▼
                             ┌─────────┐
                             │   BKP2  │
                             └────┬────┘
                                  │
                                  ▼
                           ┌────────────┐
                           │ Firewall   │
                           │ Instituto  │
                           └─────┬──────┘
                                 │
                                 ▼
                           ┌────────────┐
                           │   Switch   │
                           └─────┬──────┘
                                 │
                  ┌──────────────┴──────────────┐
                  │                             │
                  ▼                             ▼
            ┌───────────┐                 ┌───────────┐
            │  Proxmox  │                 │ PC Clase  │
            └─────┬─────┘                 └───────────┘
                  │
                  ▼
            ┌────────────┐
            │ Firewall   │
            │  iptables  │
            └─────┬──────┘
                  │
                  ▼
            ┌────────────┐
            │    DMZ     │
            │ DHCP + IDS │
            └─────┬──────┘
                  │
                  ▼
            ┌────────────┐
            │  Bastión   │
            │ Alpine     │
            └─────┬──────┘
                  │
      ┌───────────┼───────────┬───────────┬───────────┬
      │           │           │           │           │
      ▼           ▼           ▼           ▼           ▼
   ┌─────┐     ┌─────┐     ┌─────┐     ┌─────┐     ┌─────┐
   │ FTP │     │ DNS │     │ WEB │     │  BD │     │ BKP │
   └─────┘     └─────┘     └─────┘     └─────┘     └─────┘
```

### **Seguridad**

- **Firewall**: Implementar y configurar un cortafuegos (UFW o IPTABLES). Aplicar el principio de mínimo privilegio (Ej: La base de datos solo debe aceptar conexiones entrantes desde la IP del Servidor Web, bloqueando el resto).

- **Conexión segura**: Implementación de métodos de seguridad para el acceso al servidor (ej. SSH con claves) y protección en los scripts de llamada a la base de datos (prevención de inyecciones SQL, credenciales ocultas).

• Reglas UFW: política por defecto «denegar entrada»; VM-WEB abre 443; VM-BD acepta 3306 solo desde 192.168.50.10; el bastión acepta SSH solo desde 192.168.50.10.

• Acceso por SSH con clave pública (PasswordAuthentication no, PermitRootLogin no), fail2ban y auditd en el bastión.

• Aplicación: HTTPS obligatorio, contraseñas con hash, consultas parametrizadas y copias de seguridad cifradas.
