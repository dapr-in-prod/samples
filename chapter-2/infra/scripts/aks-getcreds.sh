#!/bin/bash

TARGET=../../infra/aks-terraform
TFVARS=$TARGET/terraform.tfvars

source <(sed 's/\s//g' $TFVARS)

if [ $(az group exists --name $resourceGroup) = true ];
then
    AKSNAME=`az aks list -g $resourceGroup --query [0].name -o tsv`
else
    echo "$resourceGroup not found"
fi

echo "Cluster: $AKSNAME"

if [ ! -z "$AKSNAME" ]; then
    az aks get-credentials -g $resourceGroup -n $AKSNAME
fi

