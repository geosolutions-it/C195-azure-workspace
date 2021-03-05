# Azure Deployment

## Deploy most part of resources

```bash
export RESOURCE_GORUP=YourResourceGroup
# deploy most of resources (file share, registry private networking records, private docker registry, postgres, redis, ckan-vm)
az deployment group create --resource-group $RESOURCE_GROUP --template-file ./001_deployment.json --parameters @./parameters.json --mode Complete --confirm-with-what-if
```

## Edit setenv.sh accordingly to your parameters.json



## Deploy solr, configure resources

```bash
./azure_ckan_vm_install_docker.sh
```
