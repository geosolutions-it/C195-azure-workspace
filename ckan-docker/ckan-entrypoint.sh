#!/bin/bash
set -e

# URL for the primary database, in the format expected by sqlalchemy (required
# unless linked to a container called 'db')
: ${CKAN_SQLALCHEMY_URL:=}
# URL for solr (required unless linked to a container called 'solr')
: ${CKAN_SOLR_URL:=}
# URL for redis (required unless linked to a container called 'redis')
: ${CKAN_REDIS_URL:=}
# URL for datapusher (required unless linked to a container called 'datapusher')
: ${CKAN_DATAPUSHER_URL:=}

PGTMP=${CKAN_SQLALCHEMY_URL##*@}
CKAN_PG_HOST=${PGTMP%/*}

CONFIG_INI="${CKAN_CONFIG}/production.ini"

abort () {
  echo "$@" >&2
  exit 1
}

set_environment () {
  export CKAN_SITE_ID=${CKAN_SITE_ID}
  export CKAN_SITE_URL=${CKAN_SITE_URL}
  export CKAN_SQLALCHEMY_URL=${CKAN_SQLALCHEMY_URL}
  export CKAN_SOLR_URL=${CKAN_SOLR_URL}
  export CKAN_REDIS_URL=${CKAN_REDIS_URL}
  export CKAN_STORAGE_PATH=/var/lib/ckan
  export CKAN_DATAPUSHER_URL=${CKAN_DATAPUSHER_URL}
  export CKAN_DATASTORE_WRITE_URL=${CKAN_DATASTORE_WRITE_URL}
  export CKAN_DATASTORE_READ_URL=${CKAN_DATASTORE_READ_URL}
  export CKAN_SMTP_SERVER=${CKAN_SMTP_SERVER}
  export CKAN_SMTP_STARTTLS=${CKAN_SMTP_STARTTLS}
  export CKAN_SMTP_USER=${CKAN_SMTP_USER}
  export CKAN_SMTP_PASSWORD=${CKAN_SMTP_PASSWORD}
  export CKAN_SMTP_MAIL_FROM=${CKAN_SMTP_MAIL_FROM}
  export CKAN_MAX_UPLOAD_SIZE_MB=${CKAN_MAX_UPLOAD_SIZE_MB}
}

write_config () {
  echo "Generating config at ${CONFIG_INI}..."
  $CKAN_VENV/bin/ckan generate config "$CONFIG_INI"

}

# Wait for PostgreSQL
while ! pg_isready -h $CKAN_PG_HOST -U ckan; do
  sleep 1;
done

# If we don't already have a config file, bootstrap
if [ ! -e "$CONFIG_INI" ]; then
  write_config
else
  echo "Config at ${CONFIG_INI} already exists"
  ls -l ${CONFIG_INI}
fi

# changes to the ini file -- SHOULD BE IDEMPOTENT

crudini --set --verbose --list --list-sep=\  ${CONFIG_INI} app:main ckan.plugins c195

crudini --set --verbose ${CONFIG_INI} app:main sqlalchemy.pool_size 10
crudini --set --verbose ${CONFIG_INI} app:main sqlalchemy.echo_pool True
crudini --set --verbose ${CONFIG_INI} app:main sqlalchemy.pool_pre_ping True
crudini --set --verbose ${CONFIG_INI} app:main sqlalchemy.pool_reset_on_return rollback
crudini --set --verbose ${CONFIG_INI} app:main sqlalchemy.pool_timeout 30

crudini --set --verbose ${CONFIG_INI} DEFAULT debug True

crudini --set --verbose ${CONFIG_INI} logger_root     level DEBUG
crudini --set --verbose ${CONFIG_INI} logger_werkzeug level DEBUG
crudini --set --verbose ${CONFIG_INI} logger_ckan     level DEBUG
crudini --set --verbose ${CONFIG_INI} logger_ckanext  level DEBUG
crudini --set --verbose ${CONFIG_INI} handler_console level DEBUG

# END changes to the ini file

# Get or create CKAN_SQLALCHEMY_URL
if [ -z "$CKAN_SQLALCHEMY_URL" ]; then
  abort "ERROR: no CKAN_SQLALCHEMY_URL specified in docker-compose.yml"
fi

if [ -z "$CKAN_SOLR_URL" ]; then
    abort "ERROR: no CKAN_SOLR_URL specified in docker-compose.yml"
fi

if [ -z "$CKAN_REDIS_URL" ]; then
    abort "ERROR: no CKAN_REDIS_URL specified in docker-compose.yml"
fi

if [ -z "$CKAN_DATAPUSHER_URL" ]; then
    abort "ERROR: no CKAN_DATAPUSHER_URL specified in docker-compose.yml"
fi

echo "Setting var and venv..."
set_environment
source $CKAN_VENV/bin/activate

echo "Initting DB..."
ckan --config "$CONFIG_INI" db init

echo "Adding admin user"
ckan -c /etc/ckan/default/ckan.ini sysadmin add admin email=admin@localhost name=admin


echo 'Running command --> ' $@
exec "$@"

