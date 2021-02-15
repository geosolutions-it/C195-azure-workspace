set -x


### Info from https://docs.microsoft.com/en-us/azure/container-instances/container-instances-volume-azure-files

RESOURCE_GROUP=CREA_test_20210120
# letters and digit only
STORAGE_ACCOUNT_NAME=creastorage01
# letters and digit only OR IT WILL FAIL WITHOUT HINTS
SOLR_SHARE_NAME=solrshare
LOCATION=westeurope

# Create the storage account with the parameters
az storage account create \
    --resource-group $RESOURCE_GROUP \
    --name $STORAGE_ACCOUNT_NAME \
    --location $LOCATION \
    --sku Standard_LRS

# Create the file shares
for share in $SOLR_SHARE_NAME $PG_SHARE_NAME $CKAN_SHARE_NAME ; do
   az storage share create \
     --name $share \
     --account-name $STORAGE_ACCOUNT_NAME

STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query "[0].value" --output tsv)
echo $STORAGE_KEY

