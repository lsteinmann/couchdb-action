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

echo "Creating database"
curl -X PUT "http://127.0.0.1:3001/rtest"

echo "Adding document"
curl -X POST -H "Content-Type: application/json" -d '{ "resource": { "relations": { "isRecordedIn": [ "15754929-dd98-acfa-bfc2-016b4d5582fe" ] }, "identifier": "Befund_6", "processor": [ "Henriëtte Sönderßeichen" ], "id": "02932bc4-22ce-3080-a205-e050b489c0c2" } }' "http://127.0.0.1:3001/rtest"
