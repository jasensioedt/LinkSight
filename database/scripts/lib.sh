#!/usr/bin/env bash
# Funciones comunes. Pensado para ejecutarse EN el CT de MariaDB como root.
#   Sin MYSQL_ROOT_PASSWORD ni MYSQL_HOST -> entra por el socket local como root (lo normal en Debian).
#   MYSQL_USER      usuario de la app (por defecto linksight_app)
#   MYSQL_APP_HOST  IP desde la que se conecta la web (por defecto 10.10.10.2)

: "${MYSQL_HOST:=}"
: "${MYSQL_ROOT_PASSWORD:=}"
: "${MYSQL_DATABASE:=linksight}"
: "${MYSQL_USER:=linksight_app}"
: "${MYSQL_APP_HOST:=10.10.10.2}"

log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*"; }
die() { log "ERROR: $*" >&2; exit 1; }
check_ident() { [[ "$1" =~ ^[A-Za-z0-9_]+$ ]] || die "Identificador no válido: '$1'"; }
check_ident "$MYSQL_DATABASE"; check_ident "$MYSQL_USER"
[[ "$MYSQL_APP_HOST" =~ ^[A-Za-z0-9_.%:-]+$ ]] || die "MYSQL_APP_HOST no válido: '$MYSQL_APP_HOST'"

CNF="$(mktemp)"; chmod 600 "$CNF"; trap 'rm -f "$CNF"' EXIT
{
  echo '[client]'; echo 'user=root'; echo 'default-character-set=utf8mb4'
  [ -n "$MYSQL_HOST" ] && echo "host=$MYSQL_HOST"
  if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    _pw=${MYSQL_ROOT_PASSWORD//\\/\\\\}; _pw=${_pw//\"/\\\"}; echo "password=\"$_pw\""
  fi
} > "$CNF"

if command -v mariadb >/dev/null; then CLI=mariadb; else CLI=mysql; fi
sql() { "$CLI" --defaults-extra-file="$CNF" "$@"; }

wait_for_db() {
  local tries=${1:-15}
  until sql -e 'SELECT 1' >/dev/null 2>&1; do
    tries=$((tries-1)); [ "$tries" -gt 0 ] || die "No puedo conectar a MariaDB (¿ejecutas como root en el CT?)"
    sleep 2
  done
}
