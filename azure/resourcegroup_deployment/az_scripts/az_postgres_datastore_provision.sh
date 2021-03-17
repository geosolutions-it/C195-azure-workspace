#!/bin/bash -x


export PGPASSWORD=$arg2
psql -U $arg1@$arg3 -h $arg4 postgres -c 'create database ckan with owner ckan;'
psql -U $arg1@$arg3 -h $arg4 postgres -c "CREATE ROLE datastore_ro NOSUPERUSER NOCREATEDB NOCREATEROLE LOGIN PASSWORD '${arg5}';"
psql -U $arg1@$arg3 -h $arg4 ckan -f /home/geosolutions/C195-azure-workspace/azure/azure_pg_test/00_create_datastore.sql
psql -U $arg1@$arg3 -h $arg4 datastore -f /home/geosolutions/C195-azure-workspace/azure/azure_pg_test/20_postgis_permissions.sql