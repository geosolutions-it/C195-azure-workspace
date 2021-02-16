# C195-azure-workspace

This repo contains scripts and configuration files to deploy all the services needed to run CKAN in Azure.

- `ckan-docker/` contains the configuration scripts for creating docker images for all the required services.
  Initial files have been copied from the ckan Docker configuration (https://github.com/ckan/ckan/tree/master/contrib/docker) at the time of version 2.9.1.
  More info in the README file in the directory.
- `azure/` directory contains scripts and templates to deploy service in Azure.

---

In order to be able to run the `az` commands and to make docker commands to interact with Azure, you need to perform the login procedure that will open the browser locally for the authentication steps.

Login into Azure with your tenant id; you need to specify the tenant otherwise Azure won't recognize the subscription id:

    docker login azure --tenant-id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

Create a local aci context (make sure your `docker` command is up-to-date enough to deal with ACI context, or you can get misleading error messages):

    docker context create aci azurecontext --subscription-id yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy

In order to be able to push images to the Azure registry, you have to login to the acr:

    az acr login --name <REGISTRY NAME>
