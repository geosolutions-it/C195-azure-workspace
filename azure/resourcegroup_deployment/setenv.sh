RESOURCE_GROUP=$(jq -r '.parameters.param_resource_group_name.Value' ./parameters.json)

REGISTRY_NAME=$(jq -r '.parameters.param_registry_name.Value' ./parameters.json)
REGISTRY_USERNAME=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query username | tr -d '"')
REGISTRY_PASSWORD=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query passwords[1].value | tr -d '"')

STORAGE_ACCOUNT_NAME=$(jq -r '.parameters.param_storageaccount_name.Value' ./parameters.json)
STORAGE_KEY=$(az storage account keys list -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT_NAME --query [1].value | tr -d '"')
httpEndpoint=$(az storage account show --resource-group $RESOURCE_GROUP --name $STORAGE_ACCOUNT_NAME --query "primaryEndpoints.file" | tr -d '"')

SOLR_SHARE_NAME=solrshare
PG_SHARE_NAME=pgshare
CKAN_SHARE_NAME=ckanshare

SOLR_IMAGE=crea_ckan_solr:latest
PG_IMAGE=crea_ckan_db:latest
CKAN_IMAGE=crea_ckan:latest

SOLR_CONTAINER_NAME=solr-container-test
WE_DOMAIN=westeurope.azurecontainer.io
REDIS_DOMAIN=privatelink.redis.cache.windows.net
PG_DOMAIN=privatelink.postgres.database.azure.com
VM_DOMAIN=westeurope.cloudapp.azure.com
SOLR_DOMAIN=privatelink.solr.azure.com

REDIS_HOST=$(jq -r '.parameters.param_redis_name.Value' ./parameters.json)
REDIS_NAME=$(jq -r '.parameters.param_endpoint_redis_name.Value' ./parameters.json)
# Because of bug https://github.com/Azure/azure-cli/issues/16499
SOLR_HOST=$(jq -r '.parameters.param_vnetlink_solr_name.Value' ./parameters.json)

PG_HOST=$(jq -r '.parameters.param_postgres_hostname.Value' ./parameters.json)
PG_INSTANCE=$(jq -r '.parameters.param_endpoint_pg_name.Value' ./parameters.json)
CKAN_HOST=$(jq -r '.parameters.param_vm_ckan_hostname.Value' ./parameters.json)

REDIS_AUTHKEY=$(az redis list-keys --resource-group $RESOURCE_GROUP --name $REDIS_NAME --query primaryKey | tr -d '"')

CKAN_VM_NAME=$(jq -r '.parameters.param_vm_ckan_hostname.Value' ./parameters.json)
CKAN_VM_USER=$(jq -r '.parameters.param_vm_ckan_username.Value' ./parameters.json)
CKAN_PORT=5000
CKAN_SITE_ID=default
CKAN_SITE_URL=https://${CKAN_HOST}.${VM_DOMAIN}

REDIS_HOST_FULL=${REDIS_HOST}.${REDIS_DOMAIN}
# Because of bug https://github.com/Azure/azure-cli/issues/16499
#SOLR_HOST_FULL=${SOLR_HOST}.${SOLR_DOMAIN}
SOLR_HOST_FULL=ckan_solr
PG_HOST_FULL=${PG_HOST}.${PG_DOMAIN}
CKAN_PG_USER_PARTIAL=$(jq -r '.parameters.param_postgres_username.Value' ./parameters.json)
CKAN_PG_USER=${CKAN_PG_USER_PARTIAL}@${PG_INSTANCE}
POSTGRES_PASSWORD=$(jq -r '.parameters.param_postgres_password.Value' ./parameters.json)

DATASTORE_RO_PG_USER_PARTIAL=datastore_ro
DATASTORE_RO_PG_USER=${DATASTORE_RO_PG_USER_PARTIAL}@${PG_INSTANCE}
DATASTORE_READONLY_PASSWORD=datastore
CKAN_MAX_UPLOAD_SIZE_MB=5000
CKAN_SHARE_MOUNT=/mnt/ckanshare
SOLR_SHARE_MOUNT=/mnt/solrshare

#ckan azure_auth plugin (see https://github.com/geosolutions-it/ckanext-azure-auth.git)

TENANT_IT=$(jq -r '.parameters.param_azure_auth_tenantid.Value' ./parameters.json)
CLIENT_ID=$(jq -r '.parameters.param_azure_auth_clientid.Value' ./parameters.json)
CLIENT_SECRET=$(jq -r '.parameters.param_azure_auth_client_secret.Value' ./parameters.json)