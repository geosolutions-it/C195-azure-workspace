#!/bin/bash

source setenv.sh
export PGPASSWORD=$POSTGRES_PASSWORD
psql -u CKAN_PG_USER_PARTIAL@PG_HOST PG_HOST_FULL -f ../azure_pg_test/00_create_datastore.sql
psql -u CKAN_PG_USER_PARTIAL@PG_HOST PG_HOST_FULL datastore -f ../azure_pg_test/20_postgis_permissions.sql