<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./img/linksight_fondo_oscuro.png">
  <img src="./img/linksight_fondo_claro.png" alt="Logo de LinkSight" width="280">
</picture>

### Auditoría de seguridad web y administración de sistemas

[![PHP](https://img.shields.io/badge/PHP-777BB4?style=flat-square&logo=php&logoColor=white)](#)
[![Nginx](https://img.shields.io/badge/Nginx-009639?style=flat-square&logo=nginx&logoColor=white)](#)
[![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat-square&logo=mariadb&logoColor=white)](#)
[![Rclone](https://img.shields.io/badge/Rclone-5575AA?style=flat-square)](#)

**Una aplicación web para gestionar solicitudes de auditoría y centralizar la documentación del proyecto.**

</div>

---

## 📌 Sobre el proyecto

LinkSight es un proyecto para gestionar auditorías de seguridad web. La aplicación permite crear solicitudes de análisis y almacenar sus datos en MariaDB.

El repositorio también incluye documentación sobre el alcance, la arquitectura, el modelo de amenazas, el bastión, el hardening y las copias de seguridad.

> **Uso responsable:** utiliza LinkSight únicamente para analizar sistemas propios o aquellos para los que tengas autorización explícita. La ejecución automática de análisis todavía no está conectada.

## 📚 Documentación

| Documento | Contenido |
|---|---|
| [Alcance de detección](./docs/alcance.md) | Objetivos, tipos de problemas contemplados y limitaciones. |
| [Arquitectura de red](./docs/arquitectura.md) | Diseño de red y equipos del proyecto. |
| [Arquitectura del software](./Arquitectura%20del%20Software/ArquitecturaSW.md) | Documentación de la arquitectura del software. |
| [Modelo de amenazas](./docs/amenazas.md) | Riesgos considerados en el proyecto. |
| [Instalación del bastión](./docs/instalacion_bastion.md) | Preparación del bastión. |
| [Hardening](./docs/hardening.md) | Medidas de configuración segura. |
| [Copias de seguridad con Rclone](./docs/backups-rclone.md) | Documentación de las copias de seguridad. |
| [Despliegue de la aplicación](./Web/linksight/README.md) | Documentación técnica del despliegue y la configuración de la aplicación. |

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
