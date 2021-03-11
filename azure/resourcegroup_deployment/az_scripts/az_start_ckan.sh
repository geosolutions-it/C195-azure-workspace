resourceGroupName="$arg1"
storageAccountName="$arg2"
fileShareName="$arg3"
storageAccountKey="$arg8"
registryName="$arg4"
registryUsername="$arg5"
registryPassword="$arg6"
httpEndpoint="$arg7"

cd /home/geosolutions/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose
if [ ! -f /home/geosolutions/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env ]; then
    cp /home/geosolutions/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env.sample /home/geosolutions/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env
fi    
sudo -u geosolutions docker-compose --env-file .env down
sudo -u geosolutions docker-compose --env-file .env up -d ckan
