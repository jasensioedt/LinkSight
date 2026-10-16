# Amenazas

LinkSight es una herramienta de auditoría de seguridad web capaz de detectar vulnerabilidades, errores de configuración y exposiciones de información mediante análisis automatizados. Debido a estas capacidades, existe el riesgo de que sea utilizada contra sistemas sin la autorización expresa de sus propietarios.

El uso no autorizado de este tipo de herramientas puede generar consecuencias legales, técnicas y organizativas, además de provocar interrupciones del servicio o la activación de mecanismos de defensa en los sistemas analizados. Por este motivo, LinkSight se ha diseñado para funcionar exclusivamente dentro de un contexto de auditoría autorizada, requiriendo una autorización previa y documentada antes de iniciar cualquier análisis.

Por otro lado, el servidor bastión constituye un elemento crítico de la infraestructura, ya que actúa como punto único de acceso administrativo a la plataforma. Un compromiso de este sistema podría facilitar el acceso no autorizado a los resultados de auditoría, a la configuración de la herramienta o a otros recursos internos de la infraestructura.

Para mitigar estos riesgos se aplicarán diversas medidas de seguridad:

- Autenticación mediante claves SSH.
- Principio de mínimo privilegio para usuarios y servicios.
- Segmentación de red mediante una DMZ.
- Reglas de firewall restrictivas mediante iptables.
- Registro y auditoría de accesos y actividades.
- Centralización de logs en sistemas externos.
- Actualización periódica del sistema operativo y de las dependencias.
- Restricción de los objetivos analizados a aquellos incluidos en el alcance autorizado.

Además, LinkSight incorpora un módulo de inteligencia artificial basado en Ollama para enriquecer los hallazgos obtenidos por Nuclei. Aunque este componente permite generar explicaciones y recomendaciones técnicas de forma automática, sus resultados deben considerarse como apoyo al análisis y no como una sustitución de la validación humana, ya que pueden producirse interpretaciones incorrectas o recomendaciones incompletas.

De este modo, la seguridad del proyecto no se limita únicamente a la detección de vulnerabilidades en aplicaciones web, sino también a la protección de la infraestructura de auditoría, a la trazabilidad de las acciones realizadas y a la gestión segura de la información obtenida durante los análisis.
