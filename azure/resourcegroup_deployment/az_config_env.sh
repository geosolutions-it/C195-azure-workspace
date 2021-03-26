. ./setenv.sh
cp ckan-compose/.env.sample ckan-compose/.env
echo REGISTRY_USERNAME=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query username | tr -d '"') | tee -a ckan-compose/.env
echo REGISTRY_PASSWORD=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query passwords[1].value | tr -d '"') | tee -a ckan-compose/.env
echo httpEndpoint=$(az storage account show --resource-group $RESOURCE_GROUP --name $STORAGE_ACCOUNT_NAME --query "primaryEndpoints.file" | tr -d '"') | tee -a ckan-compose/.env
echo REDIS_AUTHKEY=$(az redis list-keys --resource-group $RESOURCE_GROUP --name $REDIS_NAME --query primaryKey) | tee -a ckan-compose/.env
echo CKAN_PG_USER_PARTIAL=$(jq '.parameters.PostgreSQL_username.Value' ./parameters.json) | tee -a ckan-compose/.env
echo POSTGRES_PASSWORD=$(jq '.parameters.PostgreSQL_password.Value' ./parameters.json) | tee -a ckan-compose/.env
