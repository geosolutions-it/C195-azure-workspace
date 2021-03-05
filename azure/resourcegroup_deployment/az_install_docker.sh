#!/bin/bash

sudo apt-get -y update
sudo apt-get -y install apt-transport-https ca-certificates curl gnupg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.28.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo adduser geosolutions docker
sudo -u geosolutions git clone https://github.com/geosolutions-it/C195-azure-workspace.git /home/geosolutions/C195-azure-workspace
cd /home/geosolutions/C195-azure-workspace 
sudo -u geosolutions git checkout implementation1c
sudo -u geosolutions git submodule init && sudo -u geosolutions git submodule update

resourceGroupName="$arg1"
storageAccountName="$arg2"
fileShareName="$arg3"
storageAccountKey="$arg8"
registryName="$arg4"
registryUsername="$arg5"
registryPassword="$arg6"
mntPath="/mnt/$fileShareName"
smbCredentialFile="/etc/smbcredentials/$storageAccountName.cred"
httpEndpoint="$arg7"
smbPath=$(echo $httpEndpoint | cut -c7-$(expr length $httpEndpoint))$fileShareName

#build and push ckan and solr images

echo "$registryPassword" | sudo -u geosolutions docker login ${registryName}.azurecr.io --username $registryUsername --password-stdin 
cd /home/geosolutions/C195-azure-workspace/ckan-docker
sudo -u geosolutions docker-compose --env-file ../azure/resourcegroup_deployment/ckan-compose/.env.sample build --no-cache ckan ckan_solr && docker-compose --env-file ../azure/resourcegroup_deployment/ckan-compose/.env.sample push ckan ckan_solr

# mount ckan share

sudo mkdir -p $mntPath
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

if [ -z "$(grep $smbPath\ $mntPath /etc/fstab)" ]; then
    echo "$smbPath $mntPath cifs nofail,vers=3.0,credentials=$smbCredentialFile,serverino" | sudo tee -a /etc/fstab > /dev/null
else
    echo "/etc/fstab was not modified to avoid conflicting entries as this Azure file share was already present. You may want to double check /etc/fstab to ensure the configuration is as desired."
fi

sudo mount -a
