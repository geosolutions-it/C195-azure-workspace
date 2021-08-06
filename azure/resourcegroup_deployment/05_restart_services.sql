#!/usr/bin/env bash
set -x
source ./setenv.sh

az vm run-command invoke \
	-g ${RESOURCE_GROUP} \
	-n ${CKAN_VM_NAME} \
	--command-id RunShellScript \
	--scripts @./az_scripts/az_restart_services.sh \
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
