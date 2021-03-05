
. ./setenv.sh
# deploy most of resources (file share, registry private networking records, private docker registry, postgres, redis, ckan-vm)
az deployment group create --resource-group $RESOURCE_GROUP --template-file ./001_deployment.json --parameters ./paramameters.json --mode Complete --confirm-with-what-if

# Install docker on vm
az vm run-command invoke -g CREA_TEST_DEPLOY -n ckan-vmtest --command-id RunShellScript --scripts @./az_install_docker.sh


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