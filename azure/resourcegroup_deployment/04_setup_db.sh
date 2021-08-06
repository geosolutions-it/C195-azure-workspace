#!/usr/bin/env bash
set -x
source ./setenv.sh

# Start ckan composition

az vm run-command invoke \
	-g ${RESOURCE_GROUP} \
	-n ${CKAN_VM_NAME} \
	--command-id RunShellScript \
	--scripts @./az_scripts/az_setup_db.sh \
	--parameters \
		arg1="$CKAN_PG_USER_PARTIAL" \
		arg2="$POSTGRES_PASSWORD" \
		arg3="$PG_HOST" \
		arg4="$PG_HOST_FULL" \
		arg5="${DATASTORE_READONLY_PASSWORD}" \
		arg6="${CKAN_VM_USER}"
