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

- Copy configuration to VM
  - Previous script should have printed a full `scp` command line. Run it locally to copy local generated configuration file to VM.

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

Connect via ssh to the ckan vm, once connected issue:

```Shell
mkdir $HOME/custom-ssl
```

Copy ssl private key and full chain certificate to that location with this name convention:

- `privkey.pem` for private key
- `fullchain.pem` for certificate or in some cases (like COMODO/Sectigo certificates) a file comprised of CA, intermediate certs and the actual certificate signed by authory.

Then go to nginx configuration file:

```Shell
cd ~/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/site-confs
```

Substitute the nginx present there in file named `default` (make backup first) with this one:

```nginx
error_page 502 /502.html;
server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name _;
        return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name _;

#    include /config/nginx/ssl.conf;
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;  # about 40000 sessions
    ssl_session_tickets off;

    # intermediate configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # OCSP stapling
    ssl_stapling on;
    ssl_stapling_verify on;

    # Certificates
    ssl_certificate /home/geosolutions/custom-ssl/fullchain.pem;
    ssl_certificate_key /home/geosolutions/custom-ssl/privkey.pem;

    client_max_body_size 0;

    location / {
        include /config/nginx/proxy.conf;
        resolver 127.0.0.11 valid=30s;
        set $upstream_app ckan;
        set $upstream_port 5000;
        set $upstream_proto http;
        proxy_pass $upstream_proto://$upstream_app:$upstream_port;

    }
}
```

Go back one directory to the path of the docker compose and reload nginx:

```Shell
cd ..
docker-compose exec proxy sh
nginx -s reload
```

if all went well certificates should be no more the ones from letsencrypt
This is how let's encrypt certificates presences can be checked with openssl cli tool for linux:

```Shell
openssl s_client anaeehostname.westeurope.cloudapp.azure.com:443 < /dev/null | head
depth=2 C = US, O = Internet Security Research Group, CN = ISRG Root X1
verify return:1
depth=1 C = US, O = Let's Encrypt, CN = R3
verify return:1
depth=0 CN = anaeehostname.westeurope.cloudapp.azure.com
verify return:1
DONE
CONNECTED(00000003)
---
Certificate chain
 0 s:CN = anaeehostname.westeurope.cloudapp.azure.com
   i:C = US, O = Let's Encrypt, CN = R3
 1 s:C = US, O = Let's Encrypt, CN = R3
   i:C = US, O = Internet Security Research Group, CN = ISRG Root X1
 2 s:C = US, O = Internet Security Research Group, CN = ISRG Root X1
   i:O = Digital Signature Trust Co., CN = DST Root CA X3
---
```

After custom ssl is configured you won't see anymore "Let's Encrypt" as above in the certificate chain and you'll see your own ssl privider.
