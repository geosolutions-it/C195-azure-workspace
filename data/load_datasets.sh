#!/bin/bash

SERVER=$1
APIKEY=$2

function usage() {
  echo $0 SERVER APIKEY
}

if [ -z "$SERVER" ] ; then
  echo "Missing parameter"
  usage
  exit 1
fi

if [ -z "$APIKEY" ] ; then
  echo "Missing parameter"
  usage
  exit 1
fi

for JSON in datasets/* ; do
  echo ===
  echo UPLOADING $JSON

  curl ${SERVER}/api/3/action/package_create \
      --data @$JSON  \
      -H "Content-Type:application/json" \
      -H "Authorization:${APIKEY}"
done
