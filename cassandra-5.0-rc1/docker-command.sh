#!/bin/bash

set -e

if [ -n "${CASSANDRA_SEEDS+x}" ]; then
    if [ -z "${CASSANDRA_INITIAL_TOKENS+x}" ]; then
        echo "\$CASSANDRA_SEEDS is specified so \$CASSANDRA_INITIAL_TOKENS must also be specified but it was not"
        exit 1
    fi
    echo cassandra-test docker image: Starting in clustered mode
    cassandra -f -Dcassandra.initial_token="$CASSANDRA_INITIAL_TOKENS"
else
    echo cassandra-test docker image: Starting in non-clustered mode
    date
    date +%N
    cassandra -f -Dcassandra.skip_wait_for_gossip_to_settle=0 -Dcassandra.initial_token=0
fi
