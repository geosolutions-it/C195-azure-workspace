#!/bin/bash -x

export PGPASSWORD=$arg2

VMUSER=$arg6

psql -U $arg1@$arg3 -h $arg4 postgres -c 'create database IF NOT EXISTS ckan with owner ckan;'
psql -U $arg1@$arg3 -h $arg4 postgres -c "CREATE ROLE IF NOT EXISTS \"datastore_ro@$arg3\" NOCREATEDB NOCREATEROLE LOGIN PASSWORD \'${arg5}\';"
#psql -U $arg1@$arg3 -h $arg4 postgres -c "CREATE ROLE datastore_ro NOCREATEDB NOCREATEROLE LOGIN PASSWORD '${arg5}';"
psql -U $arg1@$arg3 -h $arg4 postgres -c "CREATE DATABASE IF NOT EXISTS datastore with OWNER ckan ENCODING 'utf-8';"
psql -U $arg1@$arg3 -h $arg4 postgres -c "GRANT ALL PRIVILEGES ON DATABASE datastore TO ckan;"
#psql -U $arg1@$arg3 -h $arg4 postgres -c "GRANT SELECT ON ALL TABLES IN DATABASE datastore TO \"datastore_ro@$arg3\";"
psql -U $arg1@$arg3 -h $arg4 datastore -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"datastore_ro@$arg3\";"
psql -U $arg1@$arg3 -h $arg4 datastore -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO \"datastore_ro@$arg3\";"
psql -U $arg1@$arg3 -h $arg4 datastore -c "CREATE EXTENSION IF NOT EXISTS postgis; ALTER VIEW geometry_columns OWNER TO ckan; ALTER TABLE spatial_ref_sys OWNER TO ckan;"