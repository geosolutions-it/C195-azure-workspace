#!/usr/bin/env bash

source /home/geosolutions/C195-azure-workspace/azure/resourcegroup_deployment/ckan-compose/.env

date=$(date '+%Y-%m-%d %H:%M:%S')
response="$(curl -I -s $CKAN_SITE_URL --max-time 10 --connect-timeout 10 | head -1 | tr -d '\r')"
if [[ "$response" != *"200"* ]]; then
    docker exec -i ckan /capture_gdb.sh      
    docker restart ckan
   	echo "$date - restarted ckan because it was stuck - check gdb stack trace" >> $HOME/ckan_restart_log
fi