<div align="center">

# LinkSight

[![GitHub](https://img.shields.io/badge/GitHub-jasensioedt-181717?style=for-the-badge&logo=github)](https://github.com/LinkSight)
[![LinkSight](https://img.shields.io/badge/LinkSight-2563EB?style=for-the-badge)](#)
[![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)](#)

**Proyecto de auditoría de seguridad web y administración de sistemas.**

</div>

---

## 🚀 Sobre el proyecto

LinkSight es un proyecto para gestionar auditorías de seguridad web. La aplicación web permite crear solicitudes de análisis y guardar sus datos en MariaDB.

El proyecto también incluye documentación sobre la arquitectura, el bastión y las copias de seguridad. La ejecución automática de los análisis está pendiente de conectar con un proceso que los ejecute.

> LinkSight solo se debe utilizar para analizar sistemas propios o con autorización explícita de su propietario.

---

## 📚 Documentación

| Documento | Descripción |
|---|---|
| [Alcance de detección](./docs/alcance.md) | Qué tipos de problemas se plantea detectar y cuáles son sus limitaciones. |
| [Arquitectura de red](./docs/arquitectura.md) | Esquema de la red y de los equipos del proyecto. |
| [Arquitectura de software](./docs/arquitecturasw.md) | Funcionalidades previstas para la aplicación. |
| [LinkSight Software](./docs/LinkSightSW.md) | Documentación del software. |
| [Modelo de amenazas](./docs/amenazas.md) | Riesgos que se tienen en cuenta en el proyecto. |
| [Instalación del bastión](./docs/instalacion_bastion.md) | Pasos para preparar el bastión. |
| [Hardening](./docs/hardening.md) | Configuración de seguridad del sistema. |
| [Backups con Rclone](./docs/backups-rclone.md) | Configuración de las copias de seguridad. |
| [Despliegue de la web](./Web/linksight/README.md) | Configuración de Docker, Nginx y MariaDB. |

---

## 🧰 Tecnologías

| Parte | Tecnología |
|---|---|
| Interfaz web | HTML |
| Backups | Rclone |
| Servidor web y proxy | Nginx |
| Base de datos | MariaDB |

---

## 📁 Estructura del proyecto

```text
LinkSight/
├── docs/                 # Documentación del proyecto
├── img/                  # Imágenes
├── Web/
│   └── linksight/        # Aplicación web y archivos de despliegue
├── Arquitectura del Software/
├── Diseño/
├── CHANGELOG.md
└── README.md
```

---

## 🖥️ Despliegue

La guía de despliegue está en [`Web/linksight/README.md`](./Web/linksight/README.md). Ahí se explica cómo preparar MariaDB y arrancar los contenedores con Docker Compose.

---

## 👥 Autores

- **Joel Asensio Chavarría** ([@jasensioedt](https://github.com/jasensioedt))
- **Aleix Nicolás** ([@aleixnic](https://github.com/aleixnic))

---

