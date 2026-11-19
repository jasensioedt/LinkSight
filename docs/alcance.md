## Alcance de detección

LinkSight emplea Nuclei como motor de análisis de seguridad. La capacidad de detección de la plataforma depende de las plantillas soportadas por dicho escáner.

La herramienta está orientada a identificar:

### Errores de configuración

- Cabeceras HTTP de seguridad ausentes o mal configuradas.
- Directory Listing habilitado.
- Consolas administrativas expuestas.
- Archivos y directorios sensibles accesibles públicamente.
- Configuraciones TLS inseguras.

### Exposición de información sensible

- Repositorios Git expuestos.
- Archivos `.env`.
- Copias de seguridad accesibles.
- Archivos de configuración expuestos.
- Divulgación de versiones de software.

### Vulnerabilidades conocidas

- CVEs asociadas a aplicaciones y servicios web.
- CMS vulnerables.
- Frameworks vulnerables.
- Dependencias con vulnerabilidades conocidas.

### Vulnerabilidades web

- SQL Injection.
- Cross-Site Scripting (XSS).
- Open Redirect.
- Path Traversal.
- Local File Inclusion (LFI).
- Remote File Inclusion (RFI).
- Server-Side Request Forgery (SSRF).

### Infraestructura y servicios

- Servicios expuestos.
- Configuraciones inseguras de servidores web.
- Paneles de administración accesibles.
- Certificados TLS inválidos o caducados.

## Limitaciones

LinkSight no garantiza la detección completa de todas las categorías del OWASP Top 10.

Algunas categorías, como:

- A01 Broken Access Control
- A06 Insecure Design
- A09 Security Logging & Monitoring Failures

requieren revisión manual o acceso interno a la aplicación y no pueden identificarse de forma fiable mediante análisis automatizado externo.
