
. ./setenv.sh
set -x

az container create \
    --resource-group $RESOURCE_GROUP \
    --name $PG_CONTAINER_NAME \
    --image ${REGISTRY_NAME}.azurecr.io/${PG_IMAGE} \
    --registry-username ${REGISTRY_USERNAME} \
    --registry-password ${REGISTRY_PASSWORD} \
    --dns-name-label $PG_HOST \
    --ports 5432 \
    --cpu 2 \
    -e  POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
        DS_RO_PASS=${DATASTORE_READONLY_PASSWORD}

#    --azure-file-volume-account-name $STORAGE_ACCOUNT_NAME \
#    --azure-file-volume-account-key $STORAGE_KEY \
#    --azure-file-volume-share-name $PG_SHARE_NAME \
#    --azure-file-volume-mount-path /var/lib/postgresql/data \