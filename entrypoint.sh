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

docker exec $CONTAINER_ID curl -sS 'http://127.0.0.1:5984/rtest' -X PUT -H 'Content-Type: application/json' > /dev/null

random_number=$RANDOM
docker exec $CONTAINER_ID curl -sS 'http://127.0.0.1:5984/rtest/' -X POST -H 'Content-Type: application/json' -d '{"name": "Your Name", "random_number": "'"$random_number"'"}' > /dev/null
