#!/usr/bin/env bash
# Aplica las migraciones pendientes de db/migrations/*.sql, en orden, una sola vez cada una,
# y deja al usuario de la aplicación con privilegios mínimos.
#
#   migrate.sh                     aplica lo pendiente
#   migrate.sh --status            lista aplicadas / pendientes
#   migrate.sh --baseline VERSION  marca como aplicadas (sin ejecutarlas) todas hasta VERSION.
#                                  Úsalo UNA vez si la BD ya existía antes de este sistema:
#                                  p. ej.  --baseline 002_profile_drafts_demo
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

MIGRATIONS_DIR="${MIGRATIONS_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../migrations" && pwd)}"
DB="$MYSQL_DATABASE"
MODE="run"; BASELINE=""
case "${1:-}" in
  --status)   MODE="status" ;;
  --baseline) MODE="baseline"; BASELINE="${2:?Indica la versión, p. ej. 002_profile_drafts_demo}" ;;
  "")         ;;
  *)          die "Opción desconocida: $1" ;;
esac

wait_for_db
sql -e "CREATE DATABASE IF NOT EXISTS \`$DB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
sql "$DB" -e "CREATE TABLE IF NOT EXISTS schema_migraciones (
  version     VARCHAR(100) NOT NULL,
  checksum    CHAR(64)     NOT NULL,
  aplicada_en DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (version)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci"

shopt -s nullglob
files=("$MIGRATIONS_DIR"/*.sql)
[ "${#files[@]}" -gt 0 ] || die "No hay migraciones en $MIGRATIONS_DIR"

n_applied=$(sql -N -B "$DB" -e "SELECT COUNT(*) FROM schema_migraciones")
has_roles=$(sql -N -B -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB' AND table_name='roles'")
if [ "$MODE" = "run" ] && [ "$n_applied" = 0 ] && [ "$has_roles" != 0 ]; then
  die "La base '$DB' ya tiene tablas pero no hay historial de migraciones.
Si ya contiene 001 y 002, ejecuta una vez:  migrate.sh --baseline 002_profile_drafts_demo"
fi

pending=0
for f in "${files[@]}"; do
  version="$(basename "$f" .sql)"
  checksum="$(sha256sum "$f" | cut -d' ' -f1)"
  old="$(sql -N -B "$DB" -e "SELECT checksum FROM schema_migraciones WHERE version='$version'")"

  if [ -n "$old" ]; then
    [ "$old" = "$checksum" ] || die "La migración $version ya estaba aplicada pero el fichero ha cambiado. No se editan migraciones antiguas: crea una nueva."
    [ "$MODE" = "status" ] && log "aplicada   $version"
    continue
  fi

  case "$MODE" in
    status)   log "PENDIENTE  $version"; pending=$((pending+1)) ;;
    baseline) [[ "$version" > "$BASELINE" ]] && continue
              sql "$DB" -e "INSERT INTO schema_migraciones (version, checksum) VALUES ('$version','$checksum')"
              log "marcada como aplicada: $version" ;;
    run)      log "aplicando $version ..."
              sql "$DB" < "$f" || die "Falló $version. MySQL no revierte DDL: revisa el estado a mano antes de reintentar."
              sql "$DB" -e "INSERT INTO schema_migraciones (version, checksum) VALUES ('$version','$checksum')"
              log "OK $version"; pending=$((pending+1)) ;;
  esac
done

if [ "$MODE" = "run" ]; then
  # Mínimo privilegio: la imagen de Docker da ALL PRIVILEGES a MYSQL_USER; aquí se recorta.
  if [ -n "${MYSQL_USER:-}" ]; then
    check_ident "$MYSQL_USER"
    sql -e "REVOKE ALL PRIVILEGES ON \`$DB\`.* FROM '$MYSQL_USER'@'$MYSQL_APP_HOST'" 2>/dev/null || true
    sql -e "GRANT SELECT, INSERT, UPDATE, DELETE ON \`$DB\`.* TO '$MYSQL_USER'@'$MYSQL_APP_HOST'"
    log "Privilegios de '$MYSQL_USER'@'$MYSQL_APP_HOST': SELECT, INSERT, UPDATE, DELETE"
  fi
  log "Migraciones terminadas ($pending nuevas)."
fi
