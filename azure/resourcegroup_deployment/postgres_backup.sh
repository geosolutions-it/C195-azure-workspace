#!/bin/bash

source setenv.sh

export PGPASSWORD=$POSTGRES_PASSWORD
mkdir -p ${CKAN_SHARE_MOUNT}/database_backup
DUMP_DATE=$(date +%F_%R)
CKAN_DUMP_FILE=ckan_${DUMP_DATE}.sql
DATASTORE_DUMP_FILE=datastore_${DUMP_DATE}.sql

pg_dump -u CKAN_PG_USER_PARTIAL@PG_HOST PG_HOST_FULL ckan -f ${CKAN_SHARE_MOUNT}/database_backup/${CKAN_DUMP_FILE}
pg_dump -u CKAN_PG_USER_PARTIAL@PG_HOST PG_HOST_FULL datastore -f ${CKAN_SHARE_MOUNT}/database_backup/${DATASTORE_DUMP_FILE}