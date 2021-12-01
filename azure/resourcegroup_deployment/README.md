# Azure Deployment

Prerequisites on the machine performing deployment operations:

- These commands should be available:
  - `bash` (shell)
  - `az` (azure cli)
  - `jq` (tool for parsing json)
  - `sshpass` (tool for passig default password to ssh non-interactively)
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
    ./01_deploy_azure_resources.sh
    ```

- Install docker stuff on VM and create images.
  - Run locally:

    ```bash
    ./02_config_vm.sh
    ```

- Create configuration from local files.
  - This script will also retrieve some info from Azure, so it's not immediate, but should be quite fast anyway.
  - Run locally

    ```bash
    env -i ./03_create_env_file.sh
    ```

- Create and configure CKAN DB
  - Create CKAN DBs and assign privs
  - Run locally (calls `az` commands)

    ```bash
    ./04_setup_db.sh
    ```

- Restart services
  - Restart containers in VM (solr, ckan, nginx)
  - Run locally (calls `az` commands)

    ```bash
    ./05_restart_services.sh
    ```

- Create API Token
  1. login into CKAN as admin
  1. navigate into the admin page, API Tokens page (or in the page `http://HOST/user/ADMINUSERNAME/api-tokens`)
  1. type a mnemonic name for your token and press the "Create API Token" button
  1. copy/store your brand new token somewhere (this is the only time you can see it)

- Load initial datasets
  - Run the script (either locally or in the VM, it only uses HTTP calls):

    ```bash
    ./06_provision_initial_data.sh YOUR_API_TOKEN
    ```

## Update

### Update CREA project
Make sure you are on the proper branch for the CREA project:

```bash
cd C195-azure-workspace
git branch
  202108_cleanup
* master
````

If the current branch is not `master` switch to it

```bash
git checkout master
```

Then pull the updates:

```bash
git pull
```

### Update CKAN

Make sure you are on the proper branch for the CKAN module:

```bash
cd ~/C195-azure-workspace/ckan-docker/ckan_copy/
git branch
* 2.9
  master
````

If the current branch is not `2.9` switch to it

```bash
git checkout 2.9
```

Then pull the updates:

```bash
git pull
```

### Update the DB
There may be changes in the DB schema, so you need to update the DB.

```bash
cd ~/C195-azure-workspace/azure/resourcegroup_deployment/az_scripts
./setup_db.sh
```

The script is idempotent, so running it over and over won't create any problem.

### Rebuild docker images

Rebuild the docker images. This procedure will also get the updated extensions:

```bash
cd ~/C195-azure-workspace/ckan-docker/
./rebuild.sh
```

### Restart docker containers

Make sure you are in the `C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose` directory:

```bash
cd ~/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose
```

Stop and restart the docker containers:

```bash
docker-compose down
docker-compose up -d
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

## Custom SSL certificates

Assuming you already have a checked out project from where installation are performed:
Copy ssl private key and full chain certificate with this name convention

- `privkey.pem` for private key
- `fullchain.pem` for certificate or in some cases (like COMODO/Sectigo certificates) a file comprised of CA, intermediate certs and the actual certificate signed by authory.

into directory `~/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/site-custom-ssl`.

Re-run deployment from phase 2:

```shell
./02_config_vm.sh && env -i ./03_create_env_file.sh && ./05_restart_services.sh
```
