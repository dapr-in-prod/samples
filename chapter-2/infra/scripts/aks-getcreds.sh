#!/bin/bash

TARGET=../../infra/aks-terraform
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
    az aks get-credentials -g $resource_group -n $AKSNAME
fi

