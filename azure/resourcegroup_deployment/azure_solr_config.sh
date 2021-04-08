#!/usr/bin/env bash
set -x
source ./setenv.sh

# Start ckan composition

az vm run-command invoke \
	-g ${RESOURCE_GROUP} \
	-n ${CKAN_VM_NAME} \
	--command-id RunShellScript \
	--scripts @./az_scripts/az_postgres_datastore_provision.sh \
	--parameters \
		arg1="$CKAN_PG_USER_PARTIAL" \
		arg2="$POSTGRES_PASSWORD" \
		arg3="$PG_HOST" \
		arg4="$PG_HOST_FULL" \
		arg5="${DATASTORE_READONLY_PASSWORD}" \
		arg6="${CKAN_VM_USER}"

az vm run-command invoke \
	-g ${RESOURCE_GROUP} \
	-n ${CKAN_VM_NAME} \
	--command-id RunShellScript \
	--scripts @./az_scripts/az_start_ckan.sh \
	--parameters \
		arg1="$RESOURCE_GROUP" \
		arg2="$STORAGE_ACCOUNT_NAME" \
		arg3="$CKAN_SHARE_NAME" \
		arg4="$REGISTRY_NAME" \
		arg5="$REGISTRY_USERNAME" \
		arg6="$REGISTRY_PASSWORD" \
		arg7="$httpEndpoint" \
		arg8="$STORAGE_KEY" \
		arg9="${CKAN_VM_USER}"
