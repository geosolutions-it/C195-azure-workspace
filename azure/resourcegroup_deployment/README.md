# Azure Deployment

Prerequisites on the machine performing deployment operations:

- These commands should be available:
  - `bash` (shell)
  - `az` (azure cli)
  - `jq` (tool for parsing json)
- must have full access or be in same resource group where the ckan stack is being deployed.

## First steps

- In Azure, create the Resource Group for the deployment
- Authenticate in azure in order to be able to run `az` commands.  
  You may either run in your terminal:  
  - `az login`: it will open a browser session where you can perform the authentication.
  - `az login -u USERNAME`: it will ask for a query in the terminal.

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

Partial customization can be also be done in file `setenv.sh`, for vars not extracted from the `parameters.json` file, but it's not needed.

It is recommended **not** to modify the params in the following list, because they are considered as fixed values in some scripts:

- `param_postgres_username = ckan`

### ADFS parameters

In order to setup ADFS integration, also edit:
- `param_azure_auth_tenantid`
- `param_azure_auth_clientid`
- `param_azure_auth_client_secret`  

When configuring the AD client, also register a callback path in Azure as `PORT://YOUR_CKAN_HOST/azure/callback`

## Deploy

- Deploy main resources in Azure.
  - This command will take up to 20-25 minutes to complete.
  - Run locally:

    ```bash
    ./azure_main_deploy.sh
    ```

- Install docker stuff on VM and create images.
  - Run locally:

    ```bash
    ./azure_ckan_vm_config.sh
    ```

- Create configuration from local files.
  - This script will also retrieve some info from Azure, so it's not immediate, but should be quite fast anyway.
  - Run locally

    ```bash
    env -i ./az_config_env.sh
    ```

- Copy configuration to VM
  - Previous script should have printed a full `scp` command line. Run it locally to copy local generated configuration file to VM.

- Create CKAN DB, restart services
  - Create CKAN DBs and assign privs, restart containers in VM (solr, ckan, nginx)
  - Run locally (calls `az` commands)
  
    ```bash
    ./azure_solr_config.sh
    ```

- Create API key
  1. login into CKAN as admin
  1. go into admin / manage
  1. regenerate API key

- Load initial datasets
  - Run the script
  
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

You may need to edit the `home` path in `az_cronjob.sh`
