RESOURCE_GROUP=CREA_TEST_DEPLOY

REGISTRY_NAME=crearegistrytest
REGISTRY_USERNAME=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query username)
REGISTRY_PASSWORD=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query passwords[1].value)

STORAGE_ACCOUNT_NAME=creastorage01test
STORAGE_KEY=$(az storage account keys list -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT_NAME --query [1].value)

SOLR_SHARE_NAME=solrshare
PG_SHARE_NAME=pgshare
CKAN_SHARE_NAME=ckanshare

SOLR_IMAGE=crea_ckan_solr:latest
PG_IMAGE=crea_ckan_db:latest
CKAN_IMAGE=crea_ckan:latest

SOLR_CONTAINER_NAME=solr-container-test
WE_DOMAIN=westeurope.azurecontainer.io
REDIS_DOMAIN=redis.cache.windows.net
PG_DOMAIN=privatelink.postgres.azure.com
VM_DOMAIN=westeurope.cloudapp.azure.com
SOLR_DOMAIN=privatelink.solr.azure.com

REDIS_HOST=crea
REDIS_NAME=crea-test
SOLR_HOST=crea-solr
PG_HOST=crea-pg
PG_INSTANCE=crea-pgtest
CKAN_HOST=ckan-vmtest

REDIS_AUTHKEY=$(az redis list-keys --resource-group $RESOURCE_GROUP --name $REDIS_NAME --query primaryKey)

CKAN_VM_NAME=ckan-vmtest
CKAN_VM_USER=geosolutions
CKAN_PORT=5000
CKAN_SITE_ID=default
CKAN_SITE_URL=http://${CKAN_HOST}.${VM_DOMAIN}:${CKAN_PORT}/

REDIS_HOST_FULL=${REDIS_HOST}.${REDIS_DOMAIN}
SOLR_HOST_FULL=${SOLR_HOST}.${SOLR_DOMAIN}
PG_HOST_FULL=${PG_HOST}.${PG_DOMAIN}
CKAN_PG_USER=geosolutions%40@${PG_INSTANCE}

DATASTORE_RO_PG_USER=datastore_ro%40@${PG_INSTANCE}
DATASTORE_READONLY_PASSWORD=datastore
POSTGRES_PASSWORD=S3cr3tP4ssw0rd
DATASTORE_READONLY_PASSWORD=postgres

CKAN_MAX_UPLOAD_SIZE_MB=5000