#!/bin/bash

TARGET_INFRA_FOLDER=../../infra/aca-terraform
APP_NAME=${PWD##*/}
REVISION=`date +"%s"`

source <(terraform -chdir=$TARGET_INFRA_FOLDER output --json | jq -r 'keys[] as $k | "\($k|ascii_upcase)=\(.[$k] | .value)"')

if [ ! $(az group exists --name $RESOURCE_GROUP) = true ];
then
    echo "$RESOURCE_GROUP not found"
    exit 1
fi

echo "Resource Group:             $RESOURCE_GROUP"
echo "Registry:                   $ACR_NAME"
echo "                            $ACR_LOGIN_SERVER"
echo "                            $ACR_PULL_ID"
echo "Container Apps Environment: $ACA_NAME"
echo "App Id + Image:             $APP_NAME"

if [ ! -z "$ACR_NAME" ] && [ ! -z "$ACA_NAME" ];
then
    if [ "$1" == "build" ];
    then
        az acr build -r $ACR_NAME -g $RESOURCE_GROUP \
            -t $APP_NAME:$REVISION .
        IMAGE=$ACR_LOGIN_SERVER/$APP_NAME:$REVISION
    else
        TAG=`az acr repository show-tags -n $ACR_NAME --repository $APP_NAME --top 1 --orderby time_desc -o tsv`
        IMAGE=$ACR_LOGIN_SERVER/$APP_NAME:$TAG
    fi

    if [ -z $(az containerapp list --environment $ACA_NAME -g $RESOURCE_GROUP --query '[?name == "$APP_NAME"].id' -o tsv)];
    then
        az containerapp create -n $APP_NAME -g $RESOURCE_GROUP \
            --environment $ACA_NAME \
            --min-replicas 1 --max-replicas 1 \
            --registry-server $ACR_LOGIN_SERVER --registry-identity $ACR_PULL_ID \
            --ingress external --target-port 5001 \
            --enable-dapr --dapr-app-id $APP_NAME --dapr-app-port 5001 \
            --image $IMAGE
    else
        az containerapp update -n $APP_NAME -g $RESOURCE_GROUP \
            --image $IMAGE
    fi

    FQDN=`az containerapp show -n $APP_NAME -g $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv`
    echo "Health test: wget -q -O- https://$FQDN/health"
fi



