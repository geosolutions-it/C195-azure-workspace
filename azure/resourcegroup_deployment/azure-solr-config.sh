. ./setenv.sh

# solr container
az container create \
    --resource-group $RESOURCE_GROUP \
    --name $SOLR_CONTAINER_NAME \
    --image ${REGISTRY_NAME}.azurecr.io/${SOLR_IMAGE} \
    --registry-username ${REGISTRY_USERNAME} \
    --registry-password ${REGISTRY_PASSWORD} \
    --ports 8983 \
    --cpu 2 \
    --azure-file-volume-account-name $STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $SOLR_SHARE_NAME \
    --azure-file-volume-mount-path /opt/solr/server/solr/ckan/data \
    --vnet privnet01 \
    --vnet-address-prefix 10.0.0.0/16 \
    --subnet default \
    --subnet-address-prefix 10.0.0.0/24 