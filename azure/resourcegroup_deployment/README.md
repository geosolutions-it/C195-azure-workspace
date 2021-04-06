# Azure Deployment

Prerequisites

- command line terminal with bash
- configured and logged in `az` cli
- `jq` tool for parsing json
- machine performing deployment operations must have full access or be in same resource group where the ckan stack is being deployed.

## Customize parameters

Customize `parameters.json` to suit your needs.

username/password are identical for vm and prostgres instance.

Many of the external resource parameters **must be customized** in `parameters.json` to be sure they are not used anywhere else in Azure by other users.

Here is a partial list:

- ResourceGroup
- AzureSubscriptionID
- Redis_crea_name
- servers_crea_pg_name
- privateEndpoints_crea_pg_name (please put this the same of servers_crea_pg_name)
- storageAccounts_creastorage01_name
- registries_crearegistry_name
- networkProfiles_aci_network_profile_privnet01_default_externalid (please update it to your subscription and resource group)

## Deploy major part of resources

This command will take up to 20-25 minutes to complete.

```bash
export RESOURCE_GROUP=CREA_TEST_DEPLOY && az deployment group create --resource-group $RESOURCE_GROUP --template-file ./001_deployment.json --parameters @./parameters.json --mode Incremental --confirm-with-what-if
```

## Configure environment on Azure CKAN VM, build docker images

- start ckan,solr docker image building.

```bash
./azure_ckan_vm_config.sh
```

- on the installation machine align `C195-azure-workspace/azure/resourcegroup_deployment/setenv.sh` and `C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env.sample` variables not taken from parameters.json

- on the installation machine run:

```bash
./az_config_env.sh
```

- copy resulting `C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env` on the very same 
  directory on the ckan-vm (a command to do that is echoed from previous script)

## Deploy solr azure container, start ckan container on vm.

Deploy a container on private network for Solr mounting a SMB share for persistent solr data and start CKAN docker container.

```bash
./azure_solr_config.sh
```

This command above is idempotent and can be run several times at once, due to a current bug in Azure CLI 
(https://github.com/Azure/azure-cli/issues/16705) this script may be needed to be run more than one for 
solr to be configured correctly

## Provision initial data to ckan

- make at least a login ad admin, got to admin user properties, regenerate api key
- run this script:

```bash
./000_provision_initial_data.sh
```

## Smoke tests

- to run smoke tests there is a script that can be run after deployment on the installation machine:

```bash
./azure_test_all.sh
```

## Restart CKAN on failures

To ensure CKAN is alyways respondig, in the CKAN vm should be run named `check_ckan_alive.sh`:

```bash
#!usr/bin/env bash
date=$(date '+%Y-%m-%d %H:%M:%S')
response="$(curl -I -s http://localhost:5000/ --max-time 10 --connect-timeout 10 | head -1 | tr -d '\r')"
if [ "$response" != 'HTTP/1.0 200 OK' ]; then
    docker exec -i ckan /capture_gdb.sh      
    docker restart ckan
   	echo "$date - restarted ckan because it was stuck" >> $HOME/ckan_restart_log
fi
```

Resulting stack traces will be found in `/mnt/ckanshare/` in a format like `/var/lib/ckan/$DATE_gdb_ckan.txt`

to configure this you can use cron like this:

```bash
*/2 * * * * $HOME/C195-azure-workspace/azure/resourcegroup_deployment/az_scripts/az_cronjob.sh
```