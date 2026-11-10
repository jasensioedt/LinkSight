#!/usr/bin/env bash
# Carga los datos de demostración (solo entorno de pruebas). Es seguro repetirlo.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
SEED="${SEED_FILE:-$(dirname "${BASH_SOURCE[0]}")/../seeds/demo.sql}"
[ "${APP_ENV:-development}" != "production" ] || die "APP_ENV=production: no se cargan datos de demo."
wait_for_db
if [ "$(sql -N -B "$MYSQL_DATABASE" -e "SELECT COUNT(*) FROM analisis WHERE codigo='A-024'")" != 0 ]; then
  log "Los datos de demo ya existen; no se hace nada."; exit 0
fi
sql "$MYSQL_DATABASE" < "$SEED"
log "Datos de demo cargados."
