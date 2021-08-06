. ./setenv.sh

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
