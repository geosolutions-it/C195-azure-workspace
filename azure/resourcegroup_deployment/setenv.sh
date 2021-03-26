RESOURCE_GROUP=$(jq '.parameters.ResourceGroup.Value' ./parameters.json)

REGISTRY_NAME=$(jq '.parameters.registries_crearegistry_name.Value' ./parameters.json)
REGISTRY_USERNAME=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query username | tr -d '"')
REGISTRY_PASSWORD=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query passwords[1].value | tr -d '"')

STORAGE_ACCOUNT_NAME=$(jq '.parameters.storageAccounts_creastorage01_name.Value' ./parameters.json)
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

REDIS_HOST=$(jq '.parameters.Redis_crea_name.Value' ./parameters.json)
REDIS_NAME=$(jq '.parameters.privateEndpoints_crea_name.Value' ./parameters.json)
SOLR_HOST=crea-solr2
PG_HOST=$(jq '.parameters.servers_crea_pg_name.Value' ./parameters.json)
PG_INSTANCE=$(jq '.parameters.privateEndpoints_crea_pg_name.Value' ./parameters.json)
CKAN_HOST=$(jq '.parameters.virtualMachines_ckan_vm_name.Value' ./parameters.json)

REDIS_AUTHKEY=$(az redis list-keys --resource-group $RESOURCE_GROUP --name $REDIS_NAME --query primaryKey)

CKAN_VM_NAME=$(jq '.parameters.virtualMachines_ckan_vm_name.Value' ./parameters.json)
CKAN_VM_USER=geosolutions
CKAN_PORT=5000
CKAN_SITE_ID=default
CKAN_SITE_URL=http://${CKAN_HOST}.${VM_DOMAIN}:${CKAN_PORT}/

REDIS_HOST_FULL=${REDIS_HOST}.${REDIS_DOMAIN}
SOLR_HOST_FULL=${SOLR_HOST}.${SOLR_DOMAIN}
PG_HOST_FULL=${PG_HOST}.${PG_DOMAIN}
CKAN_PG_USER_PARTIAL=$(jq '.parameters.PostgreSQL_username.Value' ./parameters.json)
CKAN_PG_USER=${CKAN_PG_USER_PARTIAL}%40${PG_INSTANCE}
POSTGRES_PASSWORD=$(jq '.parameters.PostgreSQL_password.Value' ./parameters.json)

DATASTORE_RO_PG_USER_PARTIAL=datastore_ro
DATASTORE_RO_PG_USER=${DATASTORE_RO_PG_USER_PARTIAL}%40${PG_INSTANCE}
DATASTORE_READONLY_PASSWORD=datastore
CKAN_MAX_UPLOAD_SIZE_MB=5000
CKAN_SHARE_MOUNT=/mnt/ckanshare