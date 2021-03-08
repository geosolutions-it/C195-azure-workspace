# Azure Deployment

## Customize parameters.json to suit your needs, username/password are identical for vm and prostgres instance.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "Redis_crea_name": {
      "Value": "crea-test"
    },
    "privateEndpoints_crea_name": {
      "Value": "crea-test"
    },
    "virtualMachines_ckan_vm_name": {
      "Value": "ckan-vmtest"
    },
    "virtualMachines_ckan_vm_username": {
      "Value": "geosolutions"
    },
    "virtualMachines_ckan_vm_password": {
      "Value": "S3cre3tP4ssw0rd"
    },
    "servers_crea_pg_name": {
      "Value": "creapostgresql"
    },
    "privateEndpoints_crea_pg_name": {
      "Value": "crea-pg"
    },
    "virtualNetworks_privnet01_name": {
      "Value": "privnet01"
    },
    "networkInterfaces_ckan_vm195_name": {
      "Value": "ckan-vm195"
    },
    "publicIPAddresses_ckan_vm_ip_name": {
      "Value": "ckan-vm-ip"
    },
    "storageAccounts_creastorage01_name": {
      "Value": "creastorage01test"
    },
    "registries_crearegistry_name": {
      "Value": "crearegistrytest"
    },
    "networkSecurityGroups_ckan_vm_nsg_name": {
      "Value": "ckan-vm-nsg"
    },
    "privateDnsZones_privatelink_redis_cache_windows_net_name": {
      "Value": "privatelink.redis.cache.windows.net"
    },
    "privateDnsZones_privatelink_postgres_database_azure_com_name": {
      "Value": "privatelink.postgres.database.azure.com"
    },
    "networkInterfaces_crea_nic_2980809e_067b_47da_b39d_af39d736940d_name": {
      "Value": "crea-test.nic.2980809e-067b-47da-b39d-af39d736940d"
    },
    "networkInterfaces_crea_pg_nic_cfb98417_90b9_41be_8ec2_ec3f9d921a04_name": {
      "Value": "crea-pg-test.nic.cfb98417-90b9-41be-8ec2-ec3f9d921a04"
    },
    "networkProfiles_aci_network_profile_privnet01_default_externalid": {
      "Value": "/subscriptions/1cd0a26f-1c2a-48fb-9db5-c5be98e7603b/resourceGroups/CREA_TEST_DEPLOYMENT/providers/Microsoft.Network/networkProfiles/aci-network-profile-privnet01-default"
    }
  }
}
```

## Deploy most part of resources

```bash
export RESOURCE_GORUP=YourResourceGroup
# deploy most of resources (file share, registry private networking records, private docker registry, postgres, redis, ckan-vm)
az deployment group create --resource-group $RESOURCE_GROUP --template-file ./001_deployment.json --parameters @./parameters.json --mode Complete --confirm-with-what-if
```

## Edit azure/resourcegroup_deployment/setenv.sh accordingly to your parameters.json, most of the secrets are automatically taken from the azure resources

```bash
# you can customize this one
RESOURCE_GROUP=CREA_TEST_DEPLOY

REGISTRY_NAME=crearegistrytest
REGISTRY_USERNAME=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query username)
REGISTRY_PASSWORD=$(az acr credential show -g $RESOURCE_GROUP --name $REGISTRY_NAME --query passwords[1].value)

STORAGE_ACCOUNT_NAME=creastorage01test
STORAGE_KEY=$(az storage account keys list -g $RESOURCE_GROUP -n $STORAGE_ACCOUNT_NAME --query [1].value | tr -d '"')

SOLR_SHARE_NAME=solrshare
PG_SHARE_NAME=pgshare
CKAN_SHARE_NAME=ckanshare

SOLR_IMAGE=crea_ckan_solr:latest
PG_IMAGE=crea_ckan_db:latest
CKAN_IMAGE=crea_ckan:latest

SOLR_CONTAINER_NAME=solr-container-test
WE_DOMAIN=westeurope.azurecontainer.io
REDIS_DOMAIN=redis.cache.windows.net
PG_DOMAIN=privatelink.postgres.azure.com

REDIS_NAME=crea-test
REDIS_HOST=crea
SOLR_HOST=crea-solr
PG_HOST=crea-pg
CKAN_HOST=crea-ckan

REDIS_AUTHKEY=$(az redis list-keys --resource-group $RESOURCE_GROUP --name $REDIS_NAME --query primaryKey)

CKAN_VM_NAME=ckan-vmtest
CKAN_VM_USER=geosolutions
CKAN_URL=http://${CKAN_HOST}.${WE_DOMAIN}:5000/

REDIS_HOST_FULL=${REDIS_HOST}.${REDIS_DOMAIN}
SOLR_HOST_FULL=${SOLR_HOST}.privatelink.solr.azure.com
PG_HOST_FULL=${PG_HOST}.${WE_DOMAIN}

DATASTORE_READONLY_PASSWORD=datastore
POSTGRES_PASSWORD=postgres
DATASTORE_READONLY_PASSWORD=postgres
CKAN_VM_PASSWORD=password

http_endpoint=$(az storage account show --resource-group $RESOURCE_GROUP --name $STORAGE_ACCOUNT_NAME --query "primaryEndpoints.file" | tr -d '"')

```

## Configure resources, upload default ckan and solr images to registry.

```bash
./azure_ckan_vm_config.sh
```

## Customize azure/resourcegroup_deployment/setenv.sh

- connect via ssh to the ckan vm
- edit azure/resourcegroup_deployment/setenv.sh and copy it to azure/resourcegroup_deployment/.env

## deploy a cotainer on private network for solr mounting a smb share for persistent solr data and start ckan docker container.

```bash
./azure_solr_config.sh
```

## Configure .env and build ckan image

azure/resourcegroup_deployment/setenv.sh and azure/resourcegroup_deployment/ckan-compose
