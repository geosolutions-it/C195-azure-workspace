# Azure Deployment

## Deploy most part of resources

```bash
export RESOURCE_GORUP=YourResourceGroup
# deploy most of resources (file share, registry private networking records, private docker registry, postgres, redis, ckan-vm)
az deployment group create --resource-group $RESOURCE_GROUP --template-file ./001_deployment.json --parameters @./parameters.json --mode Complete --confirm-with-what-if
```

## Edit setenv.sh accordingly to your parameters.json

```bash
# you can customize this one
RESOURCE_GROUP=CREA_TEST_DEPLOY

REGISTRY_NAME=crearegistrytest
REGISTRY_USERNAME=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query username)
REGISTRY_PASSWORD=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query passwords[1].value)

STORAGE_ACCOUNT_NAME=creastorage01test
STORAGE_KEY=$(az storage account keys list -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT_NAME --query [1].value | tr -d '"')

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

REDIS_NAME=crea-test
REDIS_HOST=crea
SOLR_HOST=crea-solr
PG_HOST=crea-pg
CKAN_HOST=crea-ckan

REDIS_AUTHKEY=$(az redis list-keys --resource-group $RESOURCE_GROUP --name $REDIS_NAME --query primaryKey)

CKAN_VM_NAME=ckan-vmtest
CKAN_VM_USER=geosolutions
CKAN_URL=http://${CKAN_HOST}.${WE_DOMAIN}:5000/

REDIS_HOST_FULL=${REDIS_HOST}.${REDIS_DOMAIN}
SOLR_HOST_FULL=${SOLR_HOST}.privatelink.solr.azure.com
PG_HOST_FULL=${PG_HOST}.${WE_DOMAIN}

DATASTORE_READONLY_PASSWORD=datastore
POSTGRES_PASSWORD=postgres
DATASTORE_READONLY_PASSWORD=postgres
CKAN_VM_PASSWORD=password

http_endpoint=$(az storage account show --resource-group $RESOURCE_GROUP --name $STORAGE_ACCOUNT_NAME --query "primaryEndpoints.file" | tr -d '"')

```

## Configure resources and deploy solr

```bash
./azure_ckan_vm_config.sh
./azure_solr_config.sh
```

## Configure .env and build ckan image

Basically you just need to copy setenv.sh into ckan-compose/.env