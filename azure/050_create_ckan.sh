
. ./setenv.sh
set -x

az container create \
    --resource-group $RESOURCE_GROUP \
    --name $CKAN_CONTAINER_NAME \
    --image ${REGISTRY_NAME}.azurecr.io/${CKAN_IMAGE} \
    --registry-username ${REGISTRY_USERNAME} \
    --registry-password ${REGISTRY_PASSWORD} \
    --dns-name-label $CKAN_HOST \
    --ports 5000 \
    --cpu 2 \
    --azure-file-volume-account-name $STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $CKAN_SHARE_NAME \
    --azure-file-volume-mount-path /var/lib/ckan \
    -e  CKAN_SQLALCHEMY_URL=postgresql://ckan:${POSTGRES_PASSWORD}@${PG_HOST_FULL}/ckan \
        CKAN_DATASTORE_WRITE_URL=postgresql://ckan:${POSTGRES_PASSWORD}@${PG_HOST_FULL}/datastore \
        CKAN_DATASTORE_READ_URL=postgresql://datastore_ro:${DATASTORE_READONLY_PASSWORD}@${PG_HOST_FULL}/datastore \
        CKAN_SOLR_URL=http://${SOLR_HOST_FULL}:8983/solr/ckan \
        CKAN_REDIS_URL=redis://${REDIS_HOST_FULL}:6379/1 \
        CKAN_DATAPUSHER_URL=http://datapusher:8800 \
        CKAN_SITE_URL=${CKAN_URL} \
        CKAN_MAX_UPLOAD_SIZE_MB=${CKAN_MAX_UPLOAD_SIZE_MB} \
        POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
        DS_RO_PASS=${DATASTORE_READONLY_PASSWORD}
