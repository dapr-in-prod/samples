#!/bin/bash

source <(terraform output --json | jq -r 'keys[] as $k | "\($k|ascii_upcase)=\(.[$k] | .value)"')

echo "Resource Group: $RESOURCE_GROUP"
echo "Cluster: $CLUSTER_NAME"

if [ ! -z "$CLUSTER_NAME" ]; then
    az aks get-credentials -g $RESOURCE_GROUP -n $CLUSTER_NAME --admin --overwrite
fi

