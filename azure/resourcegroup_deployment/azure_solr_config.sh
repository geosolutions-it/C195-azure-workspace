#!/usr/bin/env bash
set -x
source ./setenv.sh
az network private-dns record-set a add-record -g $RESOURCE_GROUP -z $SOLR_DOMAIN --ipv4-address 10.0.0.4 --record-set-name $SOLR_HOST
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

# Start ckan composition

az vm run-command invoke -g ${RESOURCE_GROUP} -n ${CKAN_VM_NAME} --command-id RunShellScript --scripts @./az_scripts/az_postgres_datastore_provision.sh --parameters arg1="$CKAN_PG_USER_PARTIAL" arg2="$POSTGRES_PASSWORD" arg3="$PG_HOST" arg4="$PG_HOST_FULL" arg5="${DATASTORE_READONLY_PASSWORD}"

az vm run-command invoke -g ${RESOURCE_GROUP} -n ${CKAN_VM_NAME} --command-id RunShellScript --scripts @./az_scripts/az_start_ckan.sh --parameters arg1="$RESOURCE_GROUP" arg2="$STORAGE_ACCOUNT_NAME" arg3="$CKAN_SHARE_NAME" arg4="$REGISTRY_NAME" arg5="$REGISTRY_USERNAME" arg6="$REGISTRY_PASSWORD" arg7="$httpEndpoint" arg8="$STORAGE_KEY"
