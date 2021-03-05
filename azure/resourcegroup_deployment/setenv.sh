#source ./setenv-secret.sh

# you can customize this one
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

REDIS_HOST=crea-test
SOLR_HOST=crea-solr
PG_HOST=crea-pg
CKAN_HOST=crea-ckan

CKAN_VM_NAME=ckan-vm
CKAN_VM_USER=geosolutions
CKAN_URL=http://${CKAN_HOST}.${WE_DOMAIN}:5000/

REDIS_HOST_FULL=${REDIS_HOST}.${WE_DOMAIN}
SOLR_HOST_FULL=${SOLR_HOST}.${WE_DOMAIN}
PG_HOST_FULL=${PG_HOST}.${WE_DOMAIN}

DATASTORE_READONLY_PASSWORD=datastore
POSTGRES_PASSWORD=postgres
DATASTORE_READONLY_PASSWORD=postgres
CKAN_VM_PASSWORD=password