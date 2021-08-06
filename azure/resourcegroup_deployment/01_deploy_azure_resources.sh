export RESOURCE_GROUP=$(jq -r '.parameters.param_resource_group_name.Value' parameters.json)

echo RESOURCE GROUPS is $RESOURCE_GROUP

az deployment group create \
   --resource-group $RESOURCE_GROUP \
   --template-file ./001_deployment.json \
   --parameters @./parameters.json \
   --mode Incremental \
   --confirm-with-what-if \
   --verbose
