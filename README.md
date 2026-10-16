#  LinkSight
 
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
LinkSight/
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
 
- [Joel Asensio] — [jasensioedt]
- [Aleix Nicolás] — [aleixnic]
---
 
 
