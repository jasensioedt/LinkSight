### 1. Uso de LinkSight sin autorización

**Qué pasa**

- **Legal:** escanear sistemas ajenos sin permiso puede encajar en acceso ilícito a sistemas o daños informáticos (arts. 197 bis y 264 del Código Penal en España), según el alcance y el efecto. Aunque no haya daño, es una infracción grave de las normas del centro o de la empresa.
- **Técnico:** genera mucho ruido (picos de conexiones, intentos de login, fingerprinting) y puede tumbar servicios frágiles por saturación. Además, los resultados son un mapa de debilidades que sirve de base para un ataque posterior.
- **Organizativo:** salta alertas del IDS/firewall, se bloquean IPs y se abre un incidente.

**Mitigación**

| Riesgo | Mitigación |
| --- | --- |
| Cualquiera puede ejecutarlo | Instalarlo solo en el bastión, con acceso restringido por grupo/usuario |
| Escaneo fuera de alcance | Autorización escrita con alcance (IPs, fechas, horario) |
| Falta de trazabilidad | Logs de cada ejecución (quién, cuándo, contra qué) enviados a un servidor externo |
| Impacto en producción | Limitar velocidad/agresividad y escanear en ventanas acordadas |
| Fuga de resultados | Cifrar los informes y limitar quién puede leerlos |
| Salida a redes externas | Reglas de firewall que solo permitan escanear los rangos autorizados |

### 2. Riesgos de un bastión comprometido

El bastión es el punto único de entrada, así que si cae, el atacante hereda la confianza que tiene hacia la red interna.

| Riesgo | Mitigación |
| --- | --- |
| **Movimiento lateral:** el atacante salta del bastión a toda la red | Segmentación y reglas estrictas: el bastión solo llega a lo necesario, por los puertos necesarios |
| **Robo de credenciales y claves** | Claves SSH con passphrase, MFA, sin contraseñas ni secretos guardados en el bastión |
| **Abuso de agent forwarding** | Desactivarlo y usar `ProxyJump` |
| **Uso de LinkSight como arma** (ya está dentro con acceso a la red) | Restringir quién lo ejecuta, limitar destinos por firewall y alertar de ejecuciones inesperadas |
| **Borrado o manipulación de logs** | Logs enviados en tiempo real a otro sistema, con permisos de solo escritura |
| **Persistencia** (backdoors, claves añadidas, cron maliciosos) | Monitorizar integridad de archivos y `authorized_keys`, y reconstruir desde imagen limpia en vez de “limpiar” |
| **Explotación del propio bastión** | Superficie mínima: sin servicios extra, parches al día, hardening de SSH (sin root, solo claves) |
| **Denegación de servicio** (se pierde el acceso a todo) | Segunda vía de acceso de emergencia y backups/snapshots de la configuración |
