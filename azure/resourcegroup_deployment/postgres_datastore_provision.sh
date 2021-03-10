#!/bin/bash


export PGPASSWORD=$arg2
psql -u $arg1@$arg3 $arg4 -f ../azure_pg_test/00_create_datastore.sql
psql -u $arg1@$arg3 $arg4 datastore -f ../azure_pg_test/20_postgis_permissions.sql