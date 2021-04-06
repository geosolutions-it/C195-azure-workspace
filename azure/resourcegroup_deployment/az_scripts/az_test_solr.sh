#!/usr/bin/env bash
DOCKER_NET=$(docker network ls -q -f name=ckan)
TEST_URL=http://ckan_solr:8983/solr/admin/cores?action=STATUS
RESULT=$(docker run --net=$DOCKER_NET --rm curlimages/curl -s $TEST_URL | grep 'name="name">ckan')
TRACE=$(docker run --net=$DOCKER_NET --rm curlimages/curl -s $TEST_URL)
[[ "$RESULT" == *"ckan"* ]] && ( echo "SOLR Instance is working" ) || ( echo "SOLR is having problems" && echo $TRACE )
