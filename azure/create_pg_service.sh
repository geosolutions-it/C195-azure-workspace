
. ./setenv.sh
set -x

TEMPLATE=azure_pg_test/parameters.template
DEST=azure_pg_test/parameters.json

cp $TEMPLATE $DEST
sed -i -e "s/POSTGRES_PASSWORD/${POSTGRES_PASSWORD}/g" $DEST
sed -i -e "s/PG_HOST/${PG_HOST}/g" $DEST


az deployment group create \
    --verbose --debug \
    --resource-group $RESOURCE_GROUP \
    --name $PG_CONTAINER_NAME \
    --template-uri https://raw.githubusercontent.com/etj/azure_pg_test/main/template.json \
    --parameters @$DEST \
    --parameters vmPasswordOrKey=${SERVICE_VM_PASSWORD}
