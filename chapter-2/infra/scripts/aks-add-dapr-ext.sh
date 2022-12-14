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
    az k8s-extension create --cluster-type managedClusters \
        --cluster-name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --name dapr \
        --extension-type Microsoft.Dapr \
        --auto-upgrade-minor-version true \
        --configuration-settings "global.ha.enabled=true" \
        --configuration-settings "dapr_placement.cluster.forceInMemoryLog=true" \
        --configuration-settings "dapr_dashboard.enabled=false"
fi
