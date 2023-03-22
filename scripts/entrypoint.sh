#!/bin/bash

# Determine region and zone
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
AZ=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/placement/availability-zone`
RACK=`echo $AZ | awk -F'-' '{print $3}'`

cat > /etc/scylla/cassandra-rackdc.properties <<- EOF
dc = ${AWS_REGION} > 
rack = ${RACK}
prefer_local = false
EOF

cp /mnt/scylla-config/scylla.yaml /etc/scylla/scylla.yaml
if [ ! -z ${SCYLLA_REPLACE_ADDRESS} ]; then echo "replace_address_first_boot: ${SCYLLA_REPLACE_ADDRESS}" >> /etc/scylla/scylla.yaml; fi

/docker-entrypoint.py