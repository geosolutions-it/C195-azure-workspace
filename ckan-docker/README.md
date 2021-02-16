This directory contains the configuration scripts for creating docker images for all the required services.

Initial files have been copied from the ckan Docker configuration (https://github.com/ckan/ckan/tree/master/contrib/docker) at the time of version 2.9.1.

Main changes and fixes are related to 

- changing images registry, in order to be able to push images to Azure
- CKAN image: using python 3.7 instead of 2.7 
- removed the use of some mounted volumes, since the setup procedure would populate local directories, that would not be present when deploying the images remotely.


Please note that in this directory there is a git submodule including the CKAN repo. This is needed in order to have CKAN deployed in the docker image.
Initial tests where made using master at around version 2.9.1 (Jan 2021)

Make sure you `docker` and `docker-compose` commands are up-to-date enough to deal with Azure context.
You can build images with the usual 

    docker-compose build

but in order to push the images to Azure with

    docker-compose push

please make sure you have logged in Azure and created the ACI context as described in the README in the root dir of this repo.

You need the scripts in the `/azure/` directory to run the pushed images.
