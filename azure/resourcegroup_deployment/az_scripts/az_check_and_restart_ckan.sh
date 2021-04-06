#!/usr/bin/env bash

CKAN_SITE_URL=$arg1
date=$(date '+%Y-%m-%d %H:%M:%S')
response="$(curl -I -s $CKAN_SITE_URL --max-time 10 --connect-timeout 10 | head -1 | tr -d '\r')"
if [ "$response" != 'HTTP/1.0 200 OK' ]; then
    docker exec -i ckan /capture_gdb.sh      
    docker restart ckan
   	echo "$date - restarted ckan because it was stuck" >> $HOME/ckan_restart_log
fi