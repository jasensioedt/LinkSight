<div align="center">

<img src="./img/linksight.png" alt="Logo de LinkSight" width="380">

### Auditoría de seguridad web y administración de sistemas

[![PHP](https://img.shields.io/badge/PHP-777BB4?style=flat-square&logo=php&logoColor=white)](https://www.php.net/)
[![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat-square&logo=nginx&logoColor=white)](https://nginx.org/)
[![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat-square&logo=mariadb&logoColor=white)](https://mariadb.org/)
[![Rclone](https://img.shields.io/badge/Rclone-5575AA?style=flat-square)](https://rclone.org/)

**Una aplicación web para gestionar solicitudes de auditoría y centralizar la documentación del proyecto.**

</div>

---

## 📌 Sobre el proyecto

LinkSight es un proyecto para gestionar auditorías de seguridad web. La aplicación permite crear solicitudes de análisis y almacenar sus datos en MariaDB.

El repositorio también incluye documentación sobre el alcance, la arquitectura, el modelo de amenazas, el bastión, el hardening y las copias de seguridad.

> **Uso responsable:** utiliza LinkSight únicamente para analizar sistemas propios o aquellos para los que tengas autorización explícita. La ejecución automática de análisis todavía no está implementada.

## 📚 Documentación

| Documento | Contenido |
|---|---|
| [Alcance de detección](./docs/alcance.md) | Objetivos, tipos de problemas contemplados y limitaciones. |
| [Arquitectura de red](./docs/arquitectura.md) | Diseño de red y equipos del proyecto. |
| [Modelo de amenazas](./docs/amenazas.md) | Riesgos considerados en el proyecto. |
| [Hardening](./docs/hardening.md) | Medidas de configuración segura. |
| [Instalación del bastión](./docs/instalacion_bastion.md) | Preparación del bastión. |
| [Despliegue de la aplicación](./Web/linksight/README.md) | Documentación técnica del despliegue y la configuración de la aplicación. |
| [Red interna con LXC + iptables](./Arquitectura%20del%20Software/red_interna.md) | Diseño de la red interna, NAT y reenvío de tráfico entre el contenedor LXC y la MV Nginx. |
| [Arquitectura del software](./Arquitectura%20del%20Software/ArquitecturaSW.md) | Documentación de la arquitectura del software. |
| [Copias de seguridad con Rclone](./docs/backups-rclone.md) | Documentación de las copias de seguridad. |
| [Logs automáticos de Proxmox a Discord](./docs/logs_automaticos.md) | Notificaciones automáticas de los logs de backup mediante webhooks de Discord. |

## 🧰 Tecnologías

| Componente | Tecnología |
|---|---|
| Interfaz web | HTML |
| API | PHP |
| Servidor web y proxy | Nginx |
| Base de datos | MariaDB |
| Copias de seguridad | Rclone |

## 🚀 Despliegue

Consulta la [documentación de despliegue](./Web/linksight/README.md) para ver la información técnica de configuración de la aplicación.

## 🗂️ Estructura del repositorio

```text
LinkSight/
├── Arquitectura del Software/  # Documentación de arquitectura
├── Diseño/                     # Material de diseño
├── docs/                       # Documentación técnica
├── img/                        # Logos e imágenes del proyecto
├── Web/
│   └── linksight/              # Aplicación y archivos de despliegue
├── CHANGELOG.md
└── README.md
```

## 👥 Autores

- **Joel Asensio Chavarría** — [@jasensioedt](https://github.com/jasensioedt)
- **Aleix Nicolás** — [@aleixnic](https://github.com/aleixnic)
