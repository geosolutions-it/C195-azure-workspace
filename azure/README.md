This directory contains scripts and templates to deploy services in Azure.

You have to edit the `setenv_secret.sh` settign the proper passwords and key before being able to run the scripts successfully.

Make sure you performed an 'az login' and `az acr login` as reported in the root README file before running the scripts.

The files `nnn_create_xxx.sh` are used to run one by one the services needed to ckan.
The file `setenv.sh` is needed to centralize the common settings.
