#!/bin/bash

# https://learn.microsoft.com/en-us/azure/aks/dapr#register-the-kubernetesconfiguration-service-provider

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
    az k8s-extension create --cluster-type managedClusters \
        --cluster-name $CLUSTER_NAME \
        --resource-group $RESOURCE_GROUP \
        --name dapr \
        --extension-type Microsoft.Dapr
fi
