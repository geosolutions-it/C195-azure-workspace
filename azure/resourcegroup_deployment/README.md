# Azure Deployment

Prerequisites on the machine performing deployment operations:

- These commands should be available:
  - `bash` (shell)
  - `az` (azure cli)
  - `jq` (tool for parsing json)
- must have full access or be in same resource group where the ckan stack is being deployed.

## First steps

- In Azure, create the Resource Group for the deployment
- In your shell, run `az login` and authenticate in Azure

## Customize parameters

Edit the file `parameters.json` to suit your needs.

Please note that username/password are identical for vm and postgres instance.

Many of the external resource parameters **must be customized** in `parameters.json` either because they are global in Azure or in the Azure server location.
Make sure you customize the params starting with `YOUR_` (e.g. `YOUR_VM_HOSTNAME`).

Here is a partial list:

- `param_resource_group_name`: the name of the resource group you created
- `param_subscription_id`: the subscription id for the deployment
- `param_vm_ckan_hostname`: the host name of the virtual machine; this will be part of the externally visibile FQDN
- `param_redis_name`
- `param_postgres_hostname`
- `param_endpoint_pg_name` (please put this the same of param_postgres_hostname)
- `param_storageaccount_name`: Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only.
- `param_registry_name`: Resource names may contain alpha numeric characters only and must be between 5 and 50 characters.

## Deploy main resources

This command will take up to 20-25 minutes to complete.

```bash
   ./azure_main_deploy.sh
```

## Configure environment on Azure CKAN VM, build docker images

- start ckan, solr docker image building.
  ```bash
     ./azure_ckan_vm_config.sh
  ```

- on the installation machine align `C195-azure-workspace/azure/resourcegroup_deployment/setenv.sh` and `C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env.sample` variables not taken from parameters.json

- on the installation machine run:
  ```bash
  ./az_config_env.sh
  ```
  This script will also retrieve some info from Azure, so it's not immediate, but should be quite fast anyway.


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

- make at least a login ad admin, got to admin user properties, regenerate API key
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

To ensure CKAN is always responding, there's a script named `check_ckan_alive.sh` in the CKAN VM that should be added in the `crontab`:

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

Resulting stack traces will be found in `/mnt/ckanshare/` in files named like `/var/lib/ckan/$DATE_gdb_ckan.txt`

to configure this you can use cron like this:

```bash
*/2 * * * * $HOME/C195-azure-workspace/azure/resourcegroup_deployment/az_scripts/az_cronjob.sh
```