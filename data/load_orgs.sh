SERVER=$1
APIKEY=$2

NEW_JSON=/tmp/load_org.json

function usage() {
  echo $0 SERVER APIKEY
}

if [ -z "$SERVER" ]
then
  echo "Missing parameter"
  usage
  exit 1
fi

if [ -z "$APIKEY" ]
then
  echo "Missing parameter"
  usage
  exit 1
fi

for json in orgs/* ; do
  echo ===
  echo UPLOADING $json
  sed -e s=__SERVER__=$SERVER=g $json > $NEW_JSON
  curl ${SERVER}/api/3/action/organization_create \
      --data @$NEW_JSON  -H "Content-Type:application/json" \
      -H "Authorization:${APIKEY}"
done
