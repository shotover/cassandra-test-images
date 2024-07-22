#!/bin/bash

set -e

KEY_PATH="/etc/cassandra/certs/keystore_actual.p12"

# only run on the first script run.
if [ "$(id -u)" = '0' ]; then
	if [ -f "/etc/cassandra/certs/keystore.p12" ]; then
		# copy file to avoid changing owner of bound file on the host
		cp /etc/cassandra/certs/keystore.p12 $KEY_PATH
		chown cassandra:cassandra $KEY_PATH
	fi

	# restart the script as non-root user
	exec gosu cassandra "$BASH_SOURCE" "$@"
fi

_ip_address() {
	# scrape the first non-localhost IP address of the container
	# in Swarm Mode, we often get two IPs -- the container IP, and the (shared) VIP, and the container IP should always be first
	ip address | awk '
		$1 != "inet" { next } # only lines with ip addresses
		$NF == "lo" { next } # skip loopback devices
		$2 ~ /^127[.]/ { next } # skip loopback addresses
		$2 ~ /^169[.]254[.]/ { next } # skip link-local addresses
		{
			gsub(/\/.+$/, "", $2)
			print $2
			exit
		}
	'
}

: ${CASSANDRA_RPC_ADDRESS='0.0.0.0'}

: ${CASSANDRA_LISTEN_ADDRESS='auto'}
if [ "$CASSANDRA_LISTEN_ADDRESS" = 'auto' ]; then
	CASSANDRA_LISTEN_ADDRESS="$(_ip_address)"
fi

: ${CASSANDRA_BROADCAST_ADDRESS="$CASSANDRA_LISTEN_ADDRESS"}

if [ "$CASSANDRA_BROADCAST_ADDRESS" = 'auto' ]; then
	CASSANDRA_BROADCAST_ADDRESS="$(_ip_address)"
fi
: ${CASSANDRA_BROADCAST_RPC_ADDRESS:=$CASSANDRA_BROADCAST_ADDRESS}

if [ -n "${CASSANDRA_NAME:+1}" ]; then
	: ${CASSANDRA_SEEDS:="cassandra"}
fi
: ${CASSANDRA_SEEDS:="$CASSANDRA_BROADCAST_ADDRESS"}

SED_COMMANDS="s/(- seeds:).*/\1 $CASSANDRA_SEEDS/; "

for yaml in \
	broadcast_address \
	broadcast_rpc_address \
	cluster_name \
	endpoint_snitch \
	listen_address \
	rpc_address \
	start_rpc \
	native_transport_port \
; do
	var="CASSANDRA_${yaml^^}"
	val="${!var}"
	if [ "$val" ]; then
		SED_COMMANDS="${SED_COMMANDS}s/^(# )?($yaml:).*/\2 $val/; "
	fi
done
sed -r -i "$SED_COMMANDS" $CASSANDRA_CONF/cassandra.yaml

if [ -f "$KEY_PATH" ]; then
	echo "
client_encryption_options:
    enabled: true
    keystore: $KEY_PATH
    keystore_password: password
    require_client_auth: false
" >> $CASSANDRA_CONF/cassandra.yaml
fi


SED_COMMANDS=""
for rackdc in dc rack; do
	var="CASSANDRA_${rackdc^^}"
	val="${!var}"
	if [ "$val" ]; then
		SED_COMMANDS="${SED_COMMANDS}s/^(${rackdc}=).*/\1 ${val}/; "
	fi
done
sed -r -i "$SED_COMMANDS" $CASSANDRA_CONF/cassandra-rackdc.properties

exec "$@"
