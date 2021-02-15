
. ./setenv.sh

az container create \
    --resource-group $RESOURCE_GROUP \
    --name $SOLR_CONTAINER_NAME \
    --image ${REGISTRY_NAME}.azurecr.io/${SOLR_IMAGE} \
    --registry-username ${REGISTRY_USERNAME} \
    --registry-password ${REGISTRY_PASSWORD} \
    --dns-name-label $SOLR_HOST \
    --ports 8983 \
    --cpu 2 \
    --azure-file-volume-account-name $STORAGE_ACCOUNT_NAME \
    --azure-file-volume-account-key $STORAGE_KEY \
    --azure-file-volume-share-name $SOLR_SHARE_NAME \
    --azure-file-volume-mount-path /opt/solr/server/solr/ckan/solr_data
