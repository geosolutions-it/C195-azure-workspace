#!/usr/bin/env bash
#set -x 
source ./setenv.sh

## Test ckan up using testing primer ()
ckan_up() {
    TEST_URL="https://ckan-vmtest3.westeurope.cloudapp.azure.com/testing/primer"
    RESULT=$(curl -I -s $TEST_URL | head -1)
    [[ "$RESULT" == *"200"* ]] && echo "CKAN is up and running" || echo "CKAN has problems"
}

## Test solr is up

solr_up() {
    az vm run-command invoke -g ${RESOURCE_GROUP} -n ${CKAN_VM_NAME} --command-id RunShellScript --scripts @./az_scripts/az_test_solr.sh --output json | jq -r '.value[0].message'
}

## Test  redis

redis_up() {
    az vm run-command invoke -g ${RESOURCE_GROUP} -n ${CKAN_VM_NAME} --command-id RunShellScript --scripts @./az_scripts/az_test_redis.sh --output json --parameters arg1=$REDIS_AUTHKEY arg2=$REDIS_HOST_FULL| jq -r '.value[0].message'
}

# ckan_up
# solr_up
redis_up