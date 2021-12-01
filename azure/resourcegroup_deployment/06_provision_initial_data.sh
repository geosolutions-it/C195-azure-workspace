#!/usr/bin/env bash
set -x
. ckan-compose/.env
CKAN_HOST_FULL=${CKAN_VM_NAME}.${VM_DOMAIN}

if [ $# -eq 0 ] ; then
   export PGPASSWORD=$POSTGRES_PASSWORD
   CKAN_APIKEY=$(psql -t -A -X -U ${CKAN_PG_USER_PARTIAL}@${PG_INSTANCE} -h ${PG_HOST_FULL} ckan -c "select apikey from \"user\" where name='admin';")
else
   CKAN_APIKEY=$1
fi

NEW_JSON=/tmp/load_org.json

for json in data/orgs/* ; do
  echo ===
  echo UPLOADING $json
  sed -e s=__SERVER__=${CKAN_HOST_FULL}=g $json > $NEW_JSON
  curl https://${CKAN_HOST_FULL}/api/3/action/organization_create \
      --data @$NEW_JSON  -H "Content-Type:application/json" \
      -H "Authorization:${CKAN_APIKEY}"
done

for JSON in data/datasets/* ; do
  echo ===
  echo UPLOADING $JSON

  curl https://${CKAN_HOST_FULL}/api/3/action/package_create \
      --data @$JSON  \
      -H "Content-Type:application/json" \
      -H "Authorization:${CKAN_APIKEY}"
done
