#!/bin/bash

TARGET_INFRA_FOLDER=../aks-terraform
TF_VARS=$TARGET_INFRA_FOLDER/terraform.tfvars

source <(sed -r 's/^([a-z_]+)\s+=\s+(.*)$/\U\1=\L\2/' $TF_VARS)

if [ $(az group exists --name $RESOURCE_GROUP) = true ];
then
    CLUSTER_NAME=`az aks list -g $RESOURCE_GROUP --query [0].name -o tsv`
else
    echo "$RESOURCE_GROUP not found"
fi

echo "Cluster: $CLUSTER_NAME"

if [ ! -z "$CLUSTER_NAME" ]; then
    az aks get-credentials -g $RESOURCE_GROUP -n $CLUSTER_NAME --admin
fi

