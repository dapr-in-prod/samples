#!/bin/bash

source <(terraform output | sed -r 's/^([a-z_]+)\s+=\s+(.*)$/\U\1=\L\2/')

if [ $(az group exists --name $RESOURCE_GROUP) = true ];
then
    CLUSTER_NAME=`az aks list -g $RESOURCE_GROUP --query [0].name -o tsv`
else
    echo "$RESOURCE_GROUP not found"
fi

echo "Cluster: $CLUSTER_NAME Resource Group: $RESOURCE_GROUP"

if [ ! -z "$CLUSTER_NAME" ]; then
    az aks get-credentials -g $RESOURCE_GROUP -n $CLUSTER_NAME --admin --overwrite
fi

