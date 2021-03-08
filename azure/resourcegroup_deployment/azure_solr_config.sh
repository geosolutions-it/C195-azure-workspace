#!/usr/bin/bash -x
source ./setenv.sh

# solr container
az container create \
    --resource-group $RESOURCE_GROUP \
    --name $SOLR_CONTAINER_NAME \
    --image $REGISTRY_NAME.azurecr.io/${SOLR_IMAGE} \
    --registry-username $REGISTRY_USERNAME \
    --registry-password $REGISTRY_PASSWORD \
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

# Install docker on vm
az vm run-command invoke -g ${RESOURCE_GROUP} -n ${CKAN_VM_NAME} --command-id RunShellScript --scripts @./az_start_ckan.sh --parameters $RESOURCE_GROUP $STORAGE_ACCOUNT_NAME $CKAN_SHARE_NAME $REGISTRY_NAME $REGISTRY_USERNAME $REGISTRY_PASSWORD $http_endpoint arg8=$STORAGE_KEY