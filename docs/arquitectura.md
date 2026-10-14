```
[Administrador] ──SSH (clave pública)──▶ [Bastión DMZ]
                                               │
                                ┌──────────────┴───────────────┐
                                │         VulnAuditor          │
                                │  recon → dynamic → static    │
                                │       → llm → report         │
                                └──────────────┬───────────────┘
                                               │ HTTP/HTTPS controlado
                                               ▼
                                  [Web objetivo (autorizada)]
                                               │
                                         Hallazgos JSON
                                               │
                                       LLM API (opcional)
                                               │
                                        Informe .md / .pdf
                                               │
[Administrador] ◀── SCP / SFTP desde bastión ──┘
```
