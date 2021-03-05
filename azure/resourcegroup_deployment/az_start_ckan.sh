resourceGroupName="$arg1"
storageAccountName="$arg2"
fileShareName="$arg3"
storageAccountKey="$arg8"
registryName="$arg4"
registryUsername="$arg5"
registryPassword="$arg6"
httpEndpoint="$arg7"

cd /home/geosolutions/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose
sudo -u geosolutions docker-compose --env-file .env.sample pull ckan
