#!/bin/bash

TARGET=../../infra/aca-terraform
TFVARS=$TARGET/terraform.tfvars
APPNAME=${PWD##*/}
REVISION=`date +"%s"`

source <(sed 's/\s//g' $TFVARS)

echo -e "App Id + Image: $APPNAME\nResource Group: $resource_group"

if [ $(az group exists --name $resource_group) = true ];
then
    ACRNAME=`az acr list -g $resource_group --query [0].name -o tsv`
    ACRLOGINSERVER=`az acr list -g $resource_group --query [0].loginServer -o tsv`
    ACANAME=`az containerapp env list -g $resource_group --query '[0].name' -o tsv`
    ACRPULLID=`az identity list -g $resource_group --query "[?contains(name,'acrpull')].id" -o tsv`
    KVCONSUMERID=`az identity list -g $resource_group --query "[?contains(name,'kvconsumer')].id" -o tsv`
else
    echo "$resource_group not found"
fi

echo "Registry: $ACRNAME | Container Apps Environment: $ACANAME"

if [ ! -z "$ACRNAME" ] && [ ! -z "$ACANAME" ];
then
    az acr build -r $ACRNAME -g $resource_group \
        -t $APPNAME:$REVISION -t $APPNAME:latest .

    if [ -z $(az containerapp list --environment $ACANAME -g $resource_group --query '[?name == "$APPNAME"].id' -o tsv)];
    then
        az containerapp create -n $APPNAME -g $resource_group \
            --environment $ACANAME \
            --min-replicas 1 --max-replicas 1 \
            --registry-server $ACRLOGINSERVER --registry-identity $ACRPULLID \
            --user-assigned $KVCONSUMERID \
            --ingress external --target-port 5001 \
            --enable-dapr --dapr-app-id $APPNAME --dapr-app-port 5001 \
            --image $ACRLOGINSERVER/$APPNAME:$REVISION
    else
        az containerapp update -n $APPNAME -g $resource_group \
            --image $ACRLOGINSERVER/$APPNAME:$REVISION
    fi

fi

