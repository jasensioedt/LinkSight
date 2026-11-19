#  LinkSight
 
> Plataforma de auditoría de vulnerabilidades web con acceso bastionado.  
> Detecta, analiza y reporta vulnerabilidades en aplicaciones web de forma automatizada, ejecutándose desde un servidor bastionado en DMZ para garantizar trazabilidad y seguridad operacional.
 
---
 
##  Aviso legal
 
**Esta herramienta está diseñada exclusivamente para ser usada con autorización explícita y por escrito del propietario del sistema objetivo.**
 
El uso de LinkSight contra sistemas sin autorización es ilegal y puede constituir un delito informático según el artículo 197 bis del Código Penal español. Los autores no se responsabilizan del uso indebido de esta herramienta.
 
Antes de ejecutar cualquier análisis, el sistema exige un fichero de autorización firmado (`auth.json`). Sin él, la herramienta no arranca.
 
---
 
##  ¿Qué es LinkSight?
 
LinkSight es una herramienta de auditoría de seguridad web que combina:

- **Reconocimiento pasivo** — análisis de cabeceras HTTP, cookies, certificados TLS y tecnologías expuestas
- **Detección automatizada de vulnerabilidades** — análisis mediante Nuclei para identificar errores de configuración, exposiciones de información y vulnerabilidades conocidas
- **Normalización de hallazgos** — procesamiento y unificación de resultados en un formato estándar
- **Análisis mediante IA** — enriquecimiento de hallazgos con Ollama (Llama 3.2), incluyendo explicación del riesgo y recomendaciones de mitigación
- **Generación de informes** — creación automática de informes técnicos en PDF listos para entregar al cliente

Todo el análisis se ejecuta desde un **servidor bastionado en DMZ** con acceso SSH restringido, registro de auditoría y firewall de salida controlado.
 
---
 
##  Arquitectura
 
```
[Administrador] ──SSH (clave pública)──▶ [Bastión DMZ]
                                               │
                                 ┌─────────────┴──────────────┐
                                 │         LinkSight          │
                                 │                            │
                                 │  Nuclei → Normalizador     │
                                 │         → Ollama           │
                                 │         → Reportes         │
                                 └─────────────┬──────────────┘
                                               │
                                      HTTP/HTTPS autorizado
                                               │
                                               ▼
                                    [Web objetivo autorizada]
                                               │
                                        Hallazgos JSON
                                               │
                                               ▼
                                    [Ollama (Llama 3.2)]
                                               │
                                     Análisis y fixes
                                               │
                                               ▼
                                      Informe PDF final
                                               │
                        ◀─── SCP / SFTP desde bastión ─── [Administrador]
```
 
### Componentes

| Componente | Tecnología | Descripción |
|---|---|---|
| Bastión | Alpine Linux en Proxmox | Servidor mínimo en DMZ con acceso SSH restringido |
| Firewall | iptables | Filtrado de tráfico de entrada y salida, permitiendo únicamente los accesos y destinos autorizados |
| Auditoría | auditd + syslog remoto | Registro centralizado de sesiones, comandos y eventos de seguridad |
| Motor | Python 3.11 | Orquestación del análisis, procesamiento de hallazgos y generación de informes |
| Escáner | Nuclei | Detección automatizada de vulnerabilidades web y errores de configuración |
| LLM | Ollama (Llama 3.2) | Análisis local de hallazgos y generación de recomendaciones técnicas |
| Informes | Markdown + WeasyPrint | Generación automática de informes profesionales en PDF |

---
 
##  Estructura del proyecto
 
```
LinkSight/
│
├── README.md
├── CHANGELOG.md
├── .gitignore
├── requirements.txt
│
├── docs/
│
├── bastion/
│   ├── setup.sh
│   ├── sshd_config
│   ├── iptables.rules
│   └── audit.rules
│
├── linksight/
│   ├── __init__.py
│   ├── cli.py
│   ├── auth.py
│   ├── scanner.py
│   ├── normalizer.py
│   ├── llm_client.py
│   └── reporter.py
│
├── tests/
│   ├── test_scanner.py
│   ├── test_normalizer.py
│   ├── test_llm.py
│   └── test_reporter.py
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

- **Joel Asensio Chavarría** (@jasensioedt)
- **Aleix Nicolás** (@aleixnic)
---
 
 
