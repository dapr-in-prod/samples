#!/bin/bash

source <(terraform output --json | jq -r 'keys[] as $k | "\($k|ascii_upcase)=\(.[$k] | .value)"')

if [ $(az group exists --name $RESOURCE_GROUP) = true ];
then
    CLUSTER_NAME=`az aks list -g $RESOURCE_GROUP --query [0].name -o tsv`
else
    echo "$RESOURCE_GROUP not found"
fi

echo "Cluster: $CLUSTER_NAME Resource Group: $RESOURCE_GROUP"

if [ ! -z "$CLUSTER_NAME" ]; then

    dapr init -k --enable-ha --enable-mtls=true \
        --set dapr_dashboard.enabled=false,dapr_placement.cluster.forceInMemoryLog=true

fi
