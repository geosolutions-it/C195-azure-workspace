
#!/usr/bin/env bash

source ./setenv.sh

ckan_restart() {
    az vm run-command invoke -g ${RESOURCE_GROUP} -n ${CKAN_VM_NAME} --command-id RunShellScript --scripts @./az_scripts/az_check_and_restart_ckan.sh --output json --parameters arg1=$CKAN_SITE_URL| jq -r '.value[0].message' | grep -v '^\[' | grep -v 'Enable'
}

ckan_restart