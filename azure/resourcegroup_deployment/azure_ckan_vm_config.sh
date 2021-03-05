. ./setenv.sh

# Install docker on vm
az vm run-command invoke -g ${RESOURCE_GROUP} -n ${CKAN_VM_NAME} --command-id RunShellScript --scripts @./az_install_docker.sh --parameters $RESOURCE_GROUP $STORAGE_ACCOUNT_NAME $CKAN_SHARE_NAME "$STORAGE_KEY" $REGISTRY_NAME $REGISTRY_USERNAME "$REGISTRY_PASSWORD"
