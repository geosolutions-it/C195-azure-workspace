#!/bin/bash

. ./setenv.sh

export PGPASSWORD=POSTGRES_PASSWORD
CKAN_APIKEY=$(psql -t -A -X -U ${CKAN_PG_USER_PARTIAL}@${CKAN_PG_INSTANCE} -h ${PG_HOST_FULL} ckan -c "select apikey from \"user\" where name='admin';")
NEW_JSON=/tmp/load_org.json

for json in orgs/* ; do
  echo ===
  echo UPLOADING $json
  sed -e s=__SERVER__=${CKAN_HOST_FULL}=g $json > $NEW_JSON
  curl ${CKAN_HOST_FULL}:${CKAN_PORT}/api/3/action/organization_create \
      --data @$NEW_JSON  -H "Content-Type:application/json" \
      -H "Authorization:${APIKEY}"
done

for JSON in ./datasets/* ; do
  echo ===
  echo UPLOADING $JSON

  curl ${CKAN_HOST_FULL}:${CKAN_PORT}/api/3/action/package_create \
      --data @$JSON  \
      -H "Content-Type:application/json" \
      -H "Authorization:${CKAN_APIKEY}"
done