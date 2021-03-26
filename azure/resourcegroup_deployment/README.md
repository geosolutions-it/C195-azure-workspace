# Azure Deployment

Prerequisites

- command line terminal with bash
- configured and logged in `az` cli
- `jq` tool for parsing json

## Customize parameters

Customize `parameters.json` to suit your needs.

username/password are identical for vm and prostgres instance.

Many of the external resource parameters **must be customized** in `parameters.json` to be sure they are not used anywhere else in Azure by other users.

Here is a list:

- ResourceGroup
- AzureSubscriptionID
- Redis_crea_name
- servers_crea_pg_name
- privateEndpoints_crea_pg_name (please put this the same of servers_crea_pg_name)
- storageAccounts_creastorage01_name
- registries_crearegistry_name
- networkProfiles_aci_network_profile_privnet01_default_externalid (please update it to your subscription and resource group)

## Configure environment on Azure CKAN VM, build docker images

- on the installation machine run:

```bash
./azure_config_env.sh
```

- copy resulting `C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env` on the very same directory on the ckan-vm 

- start ckan,solr docker image building.

```bash
./azure_ckan_vm_config.sh
```

## Deploy solr azure container, start ckan container on vm.

Deploy a container on private network for Solr mounting a SMB share for persistent solr data and start CKAN docker container.

```bash
./azure_solr_config.sh
```

## Restart CKAN on failures

To ensure CKAN is alyways respondig, in the CKAN vm should be created such a script named `check_ckan_alive.sh`:

```bash
#!/bin/bash
date=$(date '+%Y-%m-%d %H:%M:%S')
response="$(curl -I -s http://localhost:5000/ --max-time 10 --connect-timeout 10 | head -1 | tr -d '\r')"
if [ "$response" != 'HTTP/1.0 200 OK' ]; then 
        docker restart ckan
	echo "$date - restarted ckan because it was stuck" >> $HOME/ckan_restart_log
fi
```

and a subsequent cron job with a user which can handle docker restarts as this:

```bash
* * * * * $HOME/check_ckan_alive.sh
```