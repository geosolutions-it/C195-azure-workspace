#!/bin/bash -x
set -x

source ./setenv.sh
if [ -f "./custom-ssl/privkey.pem" ]; then
	sshpass -p $CKAN_VM_PASS scp -r custom-ssl/*.pem $CKAN_VM_USER@${CKAN_VM_NAME}.${VM_DOMAIN}:C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/site-confs
fi

export CKAN_HOST CKAN_IMAGE CKAN_MAX_UPLOAD_SIZE_MB CKAN_PG_USER \
CKAN_PG_USER_PARTIAL CKAN_PORT CKAN_SHARE_MOUNT CKAN_SHARE_NAME \
CKAN_SITE_ID CKAN_SITE_URL CKAN_VM_NAME CKAN_VM_USER DATASTORE_READONLY_PASSWORD \
DATASTORE_RO_PG_USER DATASTORE_RO_PG_USER_PARTIAL httpEndpoint PG_DOMAIN PG_HOST \
PG_HOST_FULL PG_IMAGE PG_INSTANCE PG_SHARE_NAME POSTGRES_PASSWORD REDIS_AUTHKEY \
REDIS_DOMAIN REDIS_HOST REDIS_HOST_FULL REDIS_NAME REGISTRY_NAME REGISTRY_PASSWORD \
REGISTRY_USERNAME RESOURCE_GROUP SOLR_CONTAINER_NAME SOLR_DOMAIN SOLR_HOST SOLR_HOST_FULL \
SOLR_IMAGE SOLR_SHARE_NAME STORAGE_ACCOUNT_NAME STORAGE_KEY VM_DOMAIN WE_DOMAIN SOLR_SHARE_MOUNT \
ADFS_CLIENT_ID ADFS_CLIENT_SECRET ADFS_TENANT_ID
# cp ckan-compose/.env.sample ckan-compose/.env
# echo REGISTRY_USERNAME=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query username | tr -d '"') | tee -a ckan-compose/.env
# echo REGISTRY_PASSWORD=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query passwords[1].value | tr -d '"') | tee -a ckan-compose/.env
# echo httpEndpoint=$(az storage account show --resource-group $RESOURCE_GROUP --name $STORAGE_ACCOUNT_NAME --query "primaryEndpoints.file" | tr -d '"') | tee -a ckan-compose/.env
# echo REDIS_AUTHKEY=$(az redis list-keys --resource-group $RESOURCE_GROUP --name $REDIS_NAME --query primaryKey | tr -d '"') | tee -a ckan-compose/.env
# echo CKAN_PG_USER_PARTIAL=$(jq '.parameters.param_postgres_username.Value' ./parameters.json | tr -d '"') | tee -a ckan-compose/.env
# echo POSTGRES_PASSWORD=$(jq '.parameters.param_postgres_password.Value' ./parameters.json | tr -d '"') | tee -a ckan-compose/.env

export -p > ckan-compose/.env
sed -i 's/declare -x //' ckan-compose/.env

sed -i '/OLDPWD/d'  ckan-compose/.env
sed -i '/^PWD=/d'  ckan-compose/.env
sed -i '/^SHLVL=/d'  ckan-compose/.env

echo "Please run:"
echo "scp ckan-compose/.env ${CKAN_VM_USER}@${CKAN_VM_NAME}.${VM_DOMAIN}:/home/${CKAN_VM_USER}/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env"

sshpass -p $CKAN_VM_PASS scp ckan-compose/.env ${CKAN_VM_USER}@${CKAN_VM_NAME}.${VM_DOMAIN}:/home/${CKAN_VM_USER}/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env
