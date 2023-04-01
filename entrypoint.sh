#!/bin/bash

set -euo pipefail

echo "Starting Docker container"
CONTAINER_ID=$(docker run -d -p "3001:5984" "couchdb:2.3.1")

wait_for_couchdb() {
  echo "Waiting for CouchDB..."
  hostip=$(ip route show | awk '/default/ {print $3}')

  while ! curl -f "http://${hostip}:3001/" &> /dev/null
  do
    echo "."
    sleep 1
  done
}

wait_for_couchdb

# Set up system databases
echo "Setting up CouchDB system databases"

docker exec $CONTAINER_ID curl -sS 'http://127.0.0.1:5984/_users' -X PUT -H 'Content-Type: application/json' --data '{"id":"_users","name":"_users"}' > /dev/null

docker exec $CONTAINER_ID curl -sS 'http://127.0.0.1:5984/_global_changes' -X PUT -H 'Content-Type: application/json' --data '{"id":"_global_changes","name":"_global_changes"}' > /dev/null

docker exec $CONTAINER_ID curl -sS 'http://127.0.0.1:5984/_replicator' -X PUT -H 'Content-Type: application/json' --data '{"id":"_replicator","name":"_replicator"}' > /dev/null

# Create rtest database
echo "Creating rtest + other-db databases"
docker exec $CONTAINER_ID curl 'http://127.0.0.1:5984/rtest' -X PUT -H 'Content-Type: application/json'
docker exec $CONTAINER_ID curl 'http://127.0.0.1:5984/other-db' -X PUT -H 'Content-Type: application/json'

# Add test data from file
echo "Adding test data to rtest database"
docker exec $CONTAINER_ID mkdir /testdata
docker cp inst/testdata/import.json $CONTAINER_ID:/testdata/
#docker exec $CONTAINER_ID ls -R /testdata/
#docker exec $CONTAINER_ID echo "test"
docker exec $CONTAINER_ID curl -X POST -H "Content-Type: application/json" -d @/testdata/import.json 'http://127.0.0.1:5984/rtest/_bulk_docs'

# Add a user with pwd "hallo"
echo "Adding user with password"
docker exec $CONTAINER_ID curl -X PUT "http://127.0.0.1:5984/_node/couchdb@localhost/_config/admins/R" --data-binary '"hallo"'


echo "CouchDB set up complete"