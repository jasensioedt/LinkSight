# LinkSight

Despliegue para la topología actual de Proxmox:

- Host de Docker y Nginx: `10.10.10.2`
- MariaDB externa: `192.168.111.49:3306`
- Nginx sirve el frontend en el puerto `8080` y envía `/api/` al contenedor PHP por la red privada de Compose.
- El contenedor PHP no publica ningún puerto al exterior; se conecta directamente a MariaDB.

## Preparar MariaDB

Importa una sola vez `database/init/001-schema.sql` en el CT de base de datos si todavía no has creado las tablas. El SQL original está conservado en `database/source-schema.sql`; no lo importes además del esquema adaptado.

En MariaDB crea un usuario limitado al host Docker `10.10.10.2`. Usa como contraseña el valor de `DB_PASSWORD` en `.env`:

```sql
CREATE USER 'linksight_app'@'10.10.10.2' IDENTIFIED BY 'MISMA_CLAVE_QUE_EN_ENV';
GRANT SELECT, INSERT, UPDATE, DELETE ON linksight.* TO 'linksight_app'@'10.10.10.2';
FLUSH PRIVILEGES;
```

MariaDB debe escuchar en la IP `192.168.111.49` y el firewall debe permitir el puerto `3306` desde `10.10.10.2`. Comprueba también que haya ruta entre esos dos hosts. No abras el puerto a toda la red. Con la red bridge normal de Docker, MariaDB suele ver como origen la IP del host Docker; si el firewall registra otra IP, crea el usuario para esa IP concreta en vez de usar `%`.

## Configurar y arrancar en `10.10.10.2`

Copia la carpeta `linksight` al host `10.10.10.2`, incluyendo `.env` de forma privada. Si aún no tienes `.env`, copia `.env.example`. Comprueba que `DB_HOST`, `DB_USER` y `DB_PASSWORD` coincidan con MariaDB. La plantilla ya apunta a `192.168.111.49`.

Desde esa carpeta ejecuta:

```sh
docker compose pull frontend
docker compose build --pull api
docker compose up -d
```

La web quedará en `http://10.10.10.2:8080`. Si el puerto `8080` ya está ocupado, cambia `WEB_PORT` en `.env`. La API solo se alcanza mediante el proxy Nginx como `/api/...`.

Si un proxy TLS de confianza termina HTTPS antes de llegar al contenedor Nginx, establece `APP_FORCE_HTTPS=true`; para acceso HTTP directo déjalo en `false`.

## Qué incluye

- `compose.yaml`: solo los contenedores `frontend` (Nginx) y `api` (PHP/Apache); no crea otra base de datos.
- `nginx/default.conf`: archivos estáticos, cabeceras y proxy de `/api/` hacia `api:80`.
- `Dockerfile`, `api/index.php`, `php-security.ini`: API PHP conectada a MariaDB externa.
- `index.html`, `assets/`: frontend y recursos de LinkSight.

La API crea solicitudes de análisis como `pendiente`. El esquema SQL no incluye un worker que ejecute escaneos; antes de conectarlo, limita destinos privados/internos y valida redirecciones para evitar SSRF.
