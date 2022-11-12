#!/bin/bash

TARGET=../../infra/aca-terraform
TFVARS=$TARGET/terraform.tfvars
APPNAME=${PWD##*/}
REVISION=`date +"%s"`

source <(sed 's/\s//g' $TFVARS)

echo -e "App Id + Image: $APPNAME\nResource Group: $resourceGroup"

if [ $(az group exists --name $resourceGroup) = true ];
then
    ACRNAME=`az acr list -g $resourceGroup --query [0].name -o tsv`
    ACRLOGINSERVER=`az acr list -g $resourceGroup --query [0].loginServer -o tsv`
else
    echo "$resourceGroup not found"
fi

echo "Registry: $ACRNAME"

if [ ! -z "$ACRNAME" ]; then
    az acr build -r $ACRNAME -t $APPNAME:$REVISION -t $APPNAME:latest .

    az containerapp update -n $APPNAME -g $resourceGroup \
            --image $ACRLOGINSERVER/$APPNAME:$REVISION
fi

