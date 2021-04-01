#!/bin/bash -x

sudo apt-get -y update
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg postgresql-client
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo adduser geosolutions docker
sudo -u geosolutions rm -rf /home/geosolutions/C195-azure-workspace
sudo -u geosolutions rm -rf /home/geosolutions/.docker
sudo -u geosolutions git clone https://github.com/geosolutions-it/C195-azure-workspace.git /home/geosolutions/C195-azure-workspace
cd /home/geosolutions/C195-azure-workspace 

### remove this before merging to master
sudo -u geosolutions git checkout move-solr-into-vm
###

sudo -u geosolutions git submodule init && sudo -u geosolutions git submodule update

# # ### remove this when submodule is ok
# cd /home/geosolutions/C195-azure-workspace/ckan-docker/ckan_copy
# sudo -u geosolutions git pull
# sudo -u geosolutions git checkout c195-luca
# cd /home/geosolutions/C195-azure-workspace
# # ###

resourceGroupName="$arg1"
storageAccountName="$arg2"
fileShareName="$arg3"
fileShareName2="$arg9"
storageAccountKey="$arg8"
registryName="$arg4"
registryUsername="$arg5"
registryPassword="$arg6"
mntPath1="/mnt/$fileShareName"
mntPath2="/mnt/$fileShareName2"
smbCredentialFile="/etc/smbcredentials/$storageAccountName.cred"
httpEndpoint="$arg7"
smbPath1=$(echo $httpEndpoint | cut -c7-$(expr length $httpEndpoint))$fileShareName
smbPath2=$(echo $httpEndpoint | cut -c7-$(expr length $httpEndpoint))$fileShareName2

#build and push ckan and solr images

echo $registryPassword | sudo -u geosolutions docker login ${registryName}.azurecr.io --username $registryUsername --password-stdin 
cd /home/geosolutions/C195-azure-workspace/ckan-docker
sudo -u geosolutions docker-compose -f /home/geosolutions/C195-azure-workspace/ckan-docker/docker-compose.yml --env-file ../azure/resourcegroup_deployment/ckan-compose/.env.sample build ckan 
sudo -u geosolutions docker-compose -f /home/geosolutions/C195-azure-workspace/ckan-docker/docker-compose.yml --env-file ../azure/resourcegroup_deployment/ckan-compose/.env.sample build ckan_solr
cd /home/geosolutions/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose
sudo -u geosolutions docker tag crearegistry.azurecr.io/crea_ckan ${registryName}.azurecr.io/crea_ckan
sudo -u geosolutions docker tag crearegistry.azurecr.io/crea_ckan_solr ${registryName}.azurecr.io/crea_ckan_solr
sudo -u geosolutions docker push ${registryName}.azurecr.io/crea_ckan
sudo -u geosolutions docker push ${registryName}.azurecr.io/crea_ckan_solr
sudo -u geosolutions docker pull ${registryName}.azurecr.io/crea_ckan || echo "problem pulling from registry"
sudo -u geosolutions docker pull ${registryName}.azurecr.io/crea_ckan_solr || echo "problem pulling from registry"
# mount ckan share

sudo mkdir -p $mntPath1 $mntPath2

if [ ! -d "/etc/smbcredentials" ]; then
    sudo mkdir "/etc/smbcredentials"
fi

if [ ! -f $smbCredentialFile ]; then
    echo "username=$storageAccountName" | sudo tee $smbCredentialFile > /dev/null
    echo "password=$storageAccountKey" | sudo tee -a $smbCredentialFile > /dev/null
else 
    echo "The credential file $smbCredentialFile already exists, and was not modified."
fi
sudo chmod 600 $smbCredentialFile
# This command assumes you have logged in with az login

if [ -z "$(grep $smbPath1\ $mntPath1 /etc/fstab)" ]; then
    echo "$smbPath1 $mntPath1 cifs nofail,vers=3.0,credentials=$smbCredentialFile,serverino,file_mode=0777,dir_mode=0777" | sudo tee -a /etc/fstab > /dev/null
else
    echo "/etc/fstab was not modified to avoid conflicting entries as this Azure file share was already present. You may want to double check /etc/fstab to ensure the configuration is as desired."
fi

if [ -z "$(grep $smbPath2\ $mntPath2 /etc/fstab)" ]; then
    echo "$smbPath2 $mntPath2 cifs nofail,vers=3.0,credentials=$smbCredentialFile,serverino,file_mode=0777,dir_mode=0777" | sudo tee -a /etc/fstab > /dev/null
else
    echo "/etc/fstab was not modified to avoid conflicting entries as this Azure file share was already present. You may want to double check /etc/fstab to ensure the configuration is as desired."
fi
sudo mount -a