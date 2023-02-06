#!/bin/bash

TARGET_INFRA_FOLDER=../../infra/aca-terraform
REVISION=`date +"%s"`

source <(terraform -chdir=$TARGET_INFRA_FOLDER output --json | jq -r 'keys[] as $k | "\($k|ascii_upcase)=\(.[$k] | .value)"')

if [ $(az group exists --name $RESOURCE_GROUP) = true ];
then
    ACR_NAME=`az acr list -g $RESOURCE_GROUP --query "[0].name" -o tsv`
    ACR_LOGINSERVER=`az acr list -g $RESOURCE_GROUP --query "[0].loginServer" -o tsv`
    ACA_NAME=`az containerapp env list -g $RESOURCE_GROUP --query "[0].name" -o tsv`
    ACR_PULL_ID=`az identity list -g $RESOURCE_GROUP --query "[?contains(name,'acrpull')].id" -o tsv`
    KV_CONSUMER_ID=`az identity list -g $RESOURCE_GROUP --query "[?contains(name,'kvconsumer')].id" -o tsv`
else
    echo "$RESOURCE_GROUP not found"
fi

echo "Registry: $ACR_NAME | Container Apps Environment: $ACA_NAME"

declare -a APPS=("sender" "receiver")

for APP_NAME in "${APPS[@]}"
do
    echo -e "App Id + Image: $APP_NAME\nResource Group: $RESOURCE_GROUP"

    if [ ! -z "$ACR_NAME" ] && [ ! -z "$ACA_NAME" ];
    then
        if [ "$1" == "build" ];
        then
            az acr build -r $ACR_NAME -g $RESOURCE_GROUP \
                -t $APP_NAME:$REVISION -t $APP_NAME:latest $APP_NAME\

            IMAGE=$ACR_LOGINSERVER/$APP_NAME:$REVISION
        else
            IMAGE=$ACR_LOGINSERVER/$APP_NAME:latest
        fi

        if [ -z $(az containerapp list --environment $ACA_NAME -g $RESOURCE_GROUP --query '[?name == "$APP_NAME"].id' -o tsv)];
        then
            az containerapp create -n $APP_NAME -g $RESOURCE_GROUP \
                --environment $ACA_NAME \
                --min-replicas 1 --max-replicas 1 \
                --registry-server $ACR_LOGINSERVER --registry-identity $ACR_PULL_ID \
                --user-assigned $KV_CONSUMER_ID \
                --env-vars APP_PORT=5000 \
                --ingress external --target-port 5000 \
                --enable-dapr --dapr-app-id $APP_NAME --dapr-app-port 5000 \
                --dapr-enable-api-logging \
                --image $IMAGE \
                --revision-suffix ts$REVISION
        else
            az containerapp update -n $APP_NAME -g $RESOURCE_GROUP \
                --image $IMAGE \
                --revision-suffix ts$REVISION
        fi
    fi
done

for APP_NAME in "${APPS[@]}"
do
    FQDN=`az containerapp show -n $APP_NAME -g $RESOURCE_GROUP --query properties.configuration.ingress.fqdn -o tsv`
    echo "Health test: wget -q -O- http://$FQDN/health"
done


