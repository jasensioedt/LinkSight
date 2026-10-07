#  WeakScan
 
> Plataforma de auditoría de vulnerabilidades web con acceso bastionado.  
> Detecta, analiza y reporta vulnerabilidades en aplicaciones web de forma automatizada, ejecutándose desde un servidor bastionado en DMZ para garantizar trazabilidad y seguridad operacional.
 
---
 
##  Aviso legal
 
**Esta herramienta está diseñada exclusivamente para ser usada con autorización explícita y por escrito del propietario del sistema objetivo.**
 
El uso de VulnAuditor contra sistemas sin autorización es ilegal y puede constituir un delito informático según el artículo 197 bis del Código Penal español. Los autores no se responsabilizan del uso indebido de esta herramienta.
 
Antes de ejecutar cualquier análisis, el sistema exige un fichero de autorización firmado (`auth.json`). Sin él, la herramienta no arranca.
 
---
 
##  ¿Qué es VulnAuditor?
 
VulnAuditor es una herramienta de auditoría de seguridad web que combina:
 
- **Análisis de reconocimiento pasivo** — cabeceras HTTP, cookies, certificado TLS, versiones expuestas
- **Análisis dinámico** — fuzzing automatizado de SQLi, XSS, path traversal y open redirect
- **Análisis estático** — inspección del código fuente mediante AST para detectar patrones peligrosos
- **Lookup de CVEs** — cruce de dependencias contra OSV.dev y NVD
- **Validación con LLM** — enriquecimiento de hallazgos con explicación del vector de ataque y fix técnico propuesto
- **Generación de informes** — informe profesional en Markdown y PDF listo para entregar
Todo el análisis se ejecuta desde un **servidor bastionado en DMZ** con acceso SSH restringido, logging exhaustivo y firewall de salida estricto.
 
---
 
##  Arquitectura
 
```
[Administrador] ──SSH (clave pública)──▶ [Bastión DMZ]
                                               │
                                 ┌─────────────┴──────────────┐
                                 │       VulnAuditor          │
                                 │  recon → dynamic → static  │
                                 │       → llm → report       │
                                 └─────────────┬──────────────┘
                                               │  HTTP/HTTPS controlado
                                               ▼
                                     [Web objetivo (autorizada)]
                                               │
                                          Hallazgos JSON
                                               │
                                          LLM API (opcional)
                                               │
                                       Informe .md / .pdf
                                               │
                        ◀─── SCP / SFTP desde bastión ───[Administrador]
```
 
### Componentes
 
| Componente | Tecnología | Descripción |
|---|---|---|
| Bastión | Alpine Linux en Proxmox | Servidor mínimo en DMZ, solo puerto 22 |
| Firewall | nftables | Entrada solo SSH, salida solo hacia objetivos autorizados |
| Auditoría | auditd + syslog remoto | Logs de todas las sesiones y comandos |
| Motor | Python 3.x | Módulos de análisis y generación de informes |
| CVE lookup | OSV.dev API / NVD API | Detección de dependencias vulnerables |
| LLM | Claude API / OpenAI API | Validación y propuesta de fixes (opcional) |
| Informes | Markdown + pandoc/weasyprint | PDF profesional exportable |
 
---
 
##  Estructura del proyecto
 
```
weakscan/
│
├── README.md
├── CHANGELOG.md
├── .gitignore
├── requirements.txt
├── docker-compose.yml
│
├── docs/
│   ├── arquitectura.md
│   ├── alcance.md
│   ├── modelo-amenazas.md
│   ├── hardening-checklist.md
│   └── informe-template.md
│
├── bastion/
│   ├── setup.sh
│   ├── sshd_config
│   ├── nftables.conf
│   └── audit.rules
│
├── auditor/
│   ├── __init__.py
│   ├── cli.py
│   ├── auth.py
│   ├── recon.py
│   ├── dynamic.py
│   ├── static.py
│   ├── cve_lookup.py
│   ├── llm_client.py
│   └── reporter.py
│
├── tests/
│   ├── test_recon.py
│   ├── test_dynamic.py
│   └── test_static.py
│
└── reports/
```
 
---
 
##  Requisitos
 
### En el bastión
- Alpine Linux (mínimo)
- Python 3.11+
- Git
- pandoc o weasyprint (para exportar PDF)
- Acceso SSH configurado con clave pública
### En local (para desarrollo y laboratorio)
- Docker Desktop
- Python 3.11+
- Git
---
 
##  Instalación
 
### 1. Clonar el repositorio
 
```bash
git clone https://github.com/tu-usuario/weakscan.git
cd weakscan
```
 
### 2. Instalar dependencias Python
 
```bash
pip install -r requirements.txt
```
 
### 3. Levantar el entorno de laboratorio
 
```bash
docker compose up -d
```
 
Targets disponibles:
- DVWA → `http://localhost:8080`
- Juice Shop → `http://localhost:3000`
- WebGoat → `http://localhost:8888`
### 4. Crear el fichero de autorización
 
```bash
cp auth.example.json auth.json
# Editar auth.json con el target y los datos del responsable
```
 
---
 
##  Uso
 
```bash
# Solo reconocimiento pasivo
python3 auditor/cli.py --target http://localhost:8080 --mode recon
 
# Análisis dinámico completo
python3 auditor/cli.py --target http://localhost:8080 --mode dynamic
 
# Análisis estático de código fuente
python3 auditor/cli.py --mode static --source ./codigo-fuente/
 
# Análisis completo
python3 auditor/cli.py --target http://localhost:8080 --mode full
 
# Especificar carpeta de salida para el informe
python3 auditor/cli.py --target http://localhost:8080 --mode full --output ./reports/
```
 
---
 
##  Formato de hallazgo
 
Todos los módulos generan hallazgos con esta estructura estándar:
 
```json
{
  "id": "DYN-001",
  "tipo": "SQLi",
  "severidad": "alta",
  "url": "http://localhost:8080/login",
  "parametro": "username",
  "payload": "' OR '1'='1",
  "evidencia": "La respuesta contiene contenido autenticado sin credenciales válidas",
  "modulo": "dynamic",
  "fix_sugerido": null
}
```
 
---
 
##  Tests
 
```bash
# Ejecutar todos los tests
python3 -m pytest tests/
 
# Test de un módulo concreto
python3 -m pytest tests/test_dynamic.py -v
```
 
---
 
##  Fases del proyecto
 
| Fase | Descripción | Estado |
|---|---|---|
| 0 | Planificación, entorno y estructura |  En curso |
| 1 | Servidor bastionado |  Pendiente |
| 2 | Análisis dinámico |  Pendiente |
| 3 | Análisis estático |  Pendiente |
| 4 | Integración con LLM |  Pendiente |
| 5 | Generador de informes |  Pendiente |
| 6 | Integración final y demo |  Pendiente |
 
---
 
## 👥 Autores
 
- [Tu nombre] — [tu usuario de GitHub]
- [Nombre compañero] — [su usuario de GitHub]
---
 
##  Licencia
 
Este proyecto se distribuye bajo licencia MIT para uso educativo.  
Consulta el fichero `LICENSE` para más detalles.
 
