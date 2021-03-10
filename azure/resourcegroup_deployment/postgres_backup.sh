#!/bin/bash

export PGPASSWORD=$arg2
mkdir -p ${CKAN_SHARE_MOUNT}/database_backup
DUMP_DATE=$(date +%F_%R)
CKAN_DUMP_FILE=ckan_${DUMP_DATE}.sql
DATASTORE_DUMP_FILE=datastore_${DUMP_DATE}.sql

pg_dump -u $arg1@$arg3 arg4 ckan -f ${CKAN_SHARE_MOUNT}/database_backup/${CKAN_DUMP_FILE}
pg_dump -u $arg1@$arg3 arg4 datastore -f ${CKAN_SHARE_MOUNT}/database_backup/${DATASTORE_DUMP_FILE}