SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source ${SCRIPTPATH}/../ckan-compose/.env

export arg1=$CKAN_PG_USER_PARTIAL
export arg2=$POSTGRES_PASSWORD
export arg3=$PG_HOST
export arg4=$PG_HOST_FULL
export arg5=$DATASTORE_READONLY_PASSWORD
export arg6=$CKAN_VM_USER

${SCRIPTPATH}/az_setup_db.sh  "$POSTGRES_PASSWORD" $PG_HOST $PG_HOST_FULL $DATASTORE_READONLY_PASSWORD $CKAN_VM_USER
