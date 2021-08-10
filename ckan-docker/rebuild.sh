SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source ${SCRIPTPATH}/../azure/resourcegroup_deployment/ckan-compose/.env

registryName=$REGISTRY_NAME
registryUsername=$REGISTRY_USERNAME
registryPassword="$REGISTRY_PASSWORD"

vmusername=$CKAN_VM_USER

echo $registryPassword | sudo -u ${vmusername} docker login ${registryName}.azurecr.io --username $registryUsername --password-stdin

cd $SCRIPTPATH
sudo -u ${vmusername} docker-compose -f /home/${vmusername}/C195-azure-workspace/ckan-docker/docker-compose.yml --env-file ../azure/resourcegroup_deployment/ckan-compose/.env build --no-cache ckan ckan_solr

cd /home/${vmusername}/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose
sudo -u ${vmusername} docker tag crearegistry.azurecr.io/crea_ckan      ${registryName}.azurecr.io/crea_ckan
sudo -u ${vmusername} docker tag crearegistry.azurecr.io/crea_ckan_solr ${registryName}.azurecr.io/crea_ckan_solr
sudo -u ${vmusername} docker push ${registryName}.azurecr.io/crea_ckan
sudo -u ${vmusername} docker push ${registryName}.azurecr.io/crea_ckan_solr
sudo -u ${vmusername} docker pull ${registryName}.azurecr.io/crea_ckan      || echo "problem pulling from registry"
sudo -u ${vmusername} docker pull ${registryName}.azurecr.io/crea_ckan_solr || echo "problem pulling from registry"
