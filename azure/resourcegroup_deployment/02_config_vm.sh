#!/usr/bin/env bash
. ./setenv.sh
set -x
if [ -f "./custom-ssl/privkey.pem" ]; then
	sshpass -p $CKAN_VM_PASS ssh $CKAN_VM_USER@${CKAN_VM_NAME}.${VM_DOMAIN} mkdir -p custom-ssl
	sshpass -p $CKAN_VM_PASS scp -r custom-ssl/*.pem $CKAN_VM_USER@${CKAN_VM_NAME}.${VM_DOMAIN}:C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/site-confs
fi
# Install docker on vm
az vm run-command invoke \
	-g ${RESOURCE_GROUP} \
	-n ${CKAN_VM_NAME} \
	--command-id RunShellScript \
	--scripts @./az_scripts/az_config_vm.sh \
	--parameters \
		arg1="$RESOURCE_GROUP" \
		arg2="$STORAGE_ACCOUNT_NAME" \
		arg3="$CKAN_SHARE_NAME" \
		arg4="$REGISTRY_NAME" \
		arg5="$REGISTRY_USERNAME" \
		arg6="$REGISTRY_PASSWORD" \
		arg7="$httpEndpoint" \
		arg8="$STORAGE_KEY" \
		arg9="$SOLR_SHARE_NAME" \
		arg10="$CKAN_VM_USER" \
	--verbose
