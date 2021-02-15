
. ./setenv.sh

az container create \
    --resource-group $RESOURCE_GROUP \
    --name $REDIS_CONTAINER_NAME \
    --image redis:latest \
    --dns-name-label $REDIS_HOST \
    --ports 6379 
