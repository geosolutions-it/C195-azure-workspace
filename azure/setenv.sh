source ./setenv-secret.sh

# you can customize this one
RESOURCE_GROUP=CREA_test_20210120

REGISTRY_NAME=crearegistry
REGISTRY_USERNAME=crearegistry
#REGISTRY_PASSWORD=secret

STORAGE_ACCOUNT_NAME=creastorage01
#STORAGE_KEY=secret

SOLR_SHARE_NAME=solrshare
PG_SHARE_NAME=pgshare
CKAN_SHARE_NAME=ckanshare

SOLR_IMAGE=crea_ckan_solr:latest
PG_IMAGE=crea_ckan_db:latest
CKAN_IMAGE=crea_ckan:latest

REDIS_CONTAINER_NAME=redis-container
SOLR_CONTAINER_NAME=solr-container
PG_CONTAINER_NAME=pg-container
CKAN_CONTAINER_NAME=ckan-container

WE_DOMAIN=westeurope.azurecontainer.io

REDIS_HOST=crea-redis
SOLR_HOST=crea-solr
PG_HOST=crea-pg
CKAN_HOST=crea-ckan

CKAN_URL=http://${CKAN_HOST}.${WE_DOMAIN}:5000/

REDIS_HOST_FULL=${REDIS_HOST}.${WE_DOMAIN}
SOLR_HOST_FULL=${SOLR_HOST}.${WE_DOMAIN}
PG_HOST_FULL=${PG_HOST}.${WE_DOMAIN}


#POSTGRES_PASSWORD=secret
#DATASTORE_READONLY_PASSWORD=secret
