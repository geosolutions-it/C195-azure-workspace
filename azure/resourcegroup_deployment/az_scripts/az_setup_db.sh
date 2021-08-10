#!/bin/bash -x

export PGPASSWORD=$arg2

VMUSER=$arg6
PGUSER=$arg1@$arg3
STORE_RO_FULL=datastore_ro@${arg3}

psql -U $PGUSER -h $arg4 postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'ckan'" | grep -q 1 || psql -U $PGUSER -h $arg4 postgres -c 'CREATE DATABASE ckan WITH OWNER ckan;'
psql -U $PGUSER -h $arg4 ckan     -c  "CREATE EXTENSION IF NOT EXISTS postgis; ALTER VIEW geometry_columns OWNER TO ckan; ALTER TABLE spatial_ref_sys OWNER TO ckan;"

psql -U $PGUSER -h $arg4 postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = '$STORE_RO_FULL'" | grep -q 1 || psql -U $PGUSER -h $arg4 postgres -c "CREATE ROLE \"$STORE_RO_FULL\" LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION PASSWORD '${arg5}'"
psql -U $PGUSER -h $arg4 postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'datastore_ro'"   | grep -q 1 || psql -U $PGUSER -h $arg4 postgres -c "CREATE ROLE datastore_ro     LOGIN NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION PASSWORD '${arg5}'"

psql -U $PGUSER -h $arg4 postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'datastore'" | grep -q 1 || psql -U $PGUSER -h $arg4 postgres -c "CREATE DATABASE datastore WITH OWNER ckan ENCODING 'utf-8';"
psql -U $PGUSER -h $arg4 postgres -c "GRANT ALL PRIVILEGES ON DATABASE datastore TO ckan;"
psql -U $PGUSER -h $arg4 datastore -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO datastore_ro"
psql -U $PGUSER -h $arg4 datastore -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO datastore_ro;"
psql -U $PGUSER -h $arg4 datastore -c "CREATE EXTENSION IF NOT EXISTS postgis; ALTER VIEW geometry_columns OWNER TO ckan; ALTER TABLE spatial_ref_sys OWNER TO ckan;"