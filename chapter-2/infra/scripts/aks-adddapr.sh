#!/bin/bash

# https://learn.microsoft.com/en-us/azure/aks/dapr#register-the-kubernetesconfiguration-service-provider

TARGET=../aks-terraform
TFVARS=$TARGET/terraform.tfvars

source <(sed 's/\s//g' $TFVARS)

if [ $(az group exists --name $resource_group) = true ];
then
    AKSNAME=`az aks list -g $resource_group --query [0].name -o tsv`
else
    echo "$resource_group not found"
fi

echo "Cluster: $AKSNAME"

if [ ! -z "$AKSNAME" ]; then
    az k8s-extension create --cluster-type managedClusters \
        --cluster-name $AKSNAME \
        --resource-group $resource_group \
        --name dapr \
        --extension-type Microsoft.Dapr
fi
