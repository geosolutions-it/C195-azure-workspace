#!/usr/bin/env bash
#set -x 
source ./setenv.sh

## Test ckan up using testing primer ()
ckan_up() {
    TEST_URL="https://ckan-vmtest3.westeurope.cloudapp.azure.com/user/default"
    RESULT=$(curl -I -s $TEST_URL | head -1)
    [[ "$RESULT" == *"200"* ]] && echo "CKAN is up and running" || echo "CKAN has problems"
}

## Test solr is up

solr_up() {
    az vm run-command invoke -g ${RESOURCE_GROUP} -n ${CKAN_VM_NAME} --command-id RunShellScript --scripts @./az_scripts/az_test_solr.sh --output json | jq -r '.value[0].message' | grep -v '^\[' | grep -v 'Enable'
}

## Test  redis

redis_up() {
    az vm run-command invoke -g ${RESOURCE_GROUP} -n ${CKAN_VM_NAME} --command-id RunShellScript --scripts @./az_scripts/az_test_redis.sh --output json --parameters arg1=$REDIS_AUTHKEY arg2=$REDIS_HOST_FULL| jq -r '.value[0].message' |grep -v '^\[' | grep -v 'Enable'
}

ckan_works() {
    TEST_URL="https://ckan-vmtest3.westeurope.cloudapp.azure.com/testing/primer"
    RESULT=$(curl -I -s $TEST_URL | head -1)
    [[ "$RESULT" == *"200"* ]] && echo "CKAN front-end services are working!" || echo "CKAN front-end services have problems"
}

ckan_admin() {
    TEST_URL="https://ckan-vmtest3.westeurope.cloudapp.azure.com/user/admin"
    RESULT=$(curl -I -s $TEST_URL | head -1)
    [[ "$RESULT" == *"200"* ]] && echo "CKAN admin was correctly created" || echo "CKAN admin was not created"
}
ckan_null_user() {
    TEST_URL="https://ckan-vmtest3.westeurope.cloudapp.azure.com/euser/null"
    RESULT=$(curl -I -s $TEST_URL | head -1)
    [[ "$RESULT" == *"404"* ]] && echo "CKAN 404 test working!" || echo "CKAN has problems - user should not exist at install time"
}
ckan_up
solr_up
redis_up
ckan_works
ckan_admin
ckan_null_user