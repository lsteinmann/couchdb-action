#!/bin/bash

set -euo pipefail

COUCHDB_MAJOR_VERSION="${INPUT_COUCHDB_VERSION%%.*}"

echo "Running CouchDB version ${INPUT_COUCHDB_VERSION} (major version ${COUCHDB_MAJOR_VERSION}) on port ${INPUT_COUCHDB_PORT}"

EXTRA_OPTS=()

case "${COUCHDB_MAJOR_VERSION}" in
  2)
    EXTRA_OPTS+=(-p 5986:5986)
    ;;
esac

echo "Starting Docker container"
CONTAINER_ID="$(docker run -d -p "${INPUT_COUCHDB_PORT}:5984" ${EXTRA_OPTS[@]} "couchdb:${INPUT_COUCHDB_VERSION}")"

wait_for_couchdb() {
  echo "Waiting for CouchDB..."
  hostip=$(ip route show | awk '/default/ {print $3}')

  while ! curl -f "http://${hostip}:${INPUT_COUCHDB_PORT}/" &> /dev/null
  do
    echo "."
    sleep 1
  done
}

wait_for_couchdb

if [ "${COUCHDB_MAJOR_VERSION}" -gt 1 ]; then
  # Set up system databases
  echo "Setting up CouchDB system databases"
  docker exec $CONTAINER_ID curl -sS 'http://127.0.0.1:5984/_users' -X PUT -H 'Content-Type: application/json' --data '{"id":"_users","name":"_users"}' > /dev/null
  docker exec $CONTAINER_ID curl -sS 'http://127.0.0.1:5984/_global_changes' -X PUT -H 'Content-Type: application/json' --data '{"id":"_global_changes","name":"_global_changes"}' > /dev/null
  docker exec $CONTAINER_ID curl -sS 'http://127.0.0.1:5984/_replicator' -X PUT -H 'Content-Type: application/json' --data '{"id":"_replicator","name":"_replicator"}' > /dev/null
fi
