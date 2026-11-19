# Base de datos de LinkSight (MariaDB en el CT 10.10.10.3)

```
migrations/   001_schema · 002_profile_drafts_demo · 003_mantenimiento_sesiones  (historial del esquema)
seeds/        demo.sql (datos de demostración, solo pruebas)
scripts/      migrate.sh · seed.sh
```

Se ejecuta **en el CT de MariaDB, como root** (entra por el socket local, sin contraseña).

```sh
cd Web/linksight/database
bash scripts/migrate.sh            # aplica lo que falte y deja a linksight_app con SELECT/INSERT/UPDATE/DELETE
bash scripts/migrate.sh --status   # qué está aplicado
bash scripts/seed.sh               # datos de demo (solo pruebas)
```

Variables opcionales: `MYSQL_USER` (def. `linksight_app`), `MYSQL_APP_HOST` (def. `10.10.10.2`), `MYSQL_DATABASE` (def. `linksight`).
El usuario de la app debe existir antes (ver README de la web).

**Base ya creada a mano con 001 y 002:** una sola vez `bash scripts/migrate.sh --baseline 002_profile_drafts_demo`.

**Cambiar el esquema:** crea `migrations/004_nombre.sql` solo con el cambio y ejecuta `migrate.sh`.
No edites migraciones ya aplicadas (el script lo detecta y se niega).

La 003 necesita `event_scheduler=ON` (`SET GLOBAL event_scheduler=ON;` y, para que sobreviva a reinicios,
`event_scheduler=ON` en `[mysqld]` de `/etc/mysql/mariadb.conf.d/50-server.cnf`).
