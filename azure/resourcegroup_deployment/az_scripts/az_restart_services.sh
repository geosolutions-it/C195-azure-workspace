#!/bin/bash -x

resourceGroupName="$arg1"
storageAccountName="$arg2"
fileShareName="$arg3"
storageAccountKey="$arg8"
registryName="$arg4"
registryUsername="$arg5"
registryPassword="$arg6"
httpEndpoint="$arg7"
VMUSER="$arg9"

cd /home/${VMUSER}/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose
if [ ! -f /home/${VMUSER}/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env ]; then
    cp /home/${VMUSER}/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env.sample /home/${VMUSER}/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env
fi
sudo -u ${VMUSER} docker-compose --env-file .env down
sudo -u ${VMUSER} docker-compose --env-file .env up -d

if [ -f /home/${VMUSER}/custom-ssl/privkey.pem ]; then

    sudo cp /home/${VMUSER}/C195-azure-workspace/azure/resourcegroup_deployment/custom-ssl/nginx-default /home/${VMUSER}/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/site-confs/default
    sudo -u ${VMUSER} docker-compose --env-file .env down
    sudo -u ${VMUSER} docker-compose --env-file .env up -d
fi

