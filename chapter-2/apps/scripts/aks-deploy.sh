#!/bin/bash

set -e

TARGET_INFRA_FOLDER=../../infra/aks-terraform
TF_VARS=$TARGET_INFRA_FOLDER/terraform.tfvars
APP_NAME=${PWD##*/}
REVISION=`date +"%s"`
NAMESPACE=dip
AAD_IDENTITY_NAME=$APP_NAME
SUBSCRIPTION_ID=`az account show --query id -o tsv`

source <(sed -r 's/^([a-z_]+)\s+=\s+(.*)$/\U\1=\L\2/' $TF_VARS)

echo -e "App Id + Image: $APP_NAME\nResource Group: $RESOURCE_GROUP"

if [ $(az group exists --name $RESOURCE_GROUP) = true ];
then
    ACR_NAME=`az acr list -g $RESOURCE_GROUP --query [0].name -o tsv`
    ACR_LOGINSERVER=`az acr list -g $RESOURCE_GROUP --query [0].loginServer -o tsv`
    CLUSTER_NAME=`az aks list -g $RESOURCE_GROUP --query [0].name -o tsv`
    KV_NAME=`az keyvault list -g $RESOURCE_GROUP --query [0].name -o tsv`
    KV_FQDN=`az keyvault show -g $RESOURCE_GROUP -n $KV_NAME --query properties.vaultUri -o tsv | sed -e 's|^[^/]*//||' -e 's|/.*$||'`
    KV_CONSUMER_NAME=`az identity list -g $RESOURCE_GROUP --query "[?contains(name,'kvconsumer')].name" -o tsv`
    KV_CONSUMER_ID=`az identity list -g $RESOURCE_GROUP --query "[?contains(name,'kvconsumer')].id" -o tsv`
    KV_CONSUMER_CLIENT_ID=`az identity list -g $RESOURCE_GROUP --query "[?contains(name,'kvconsumer')].clientId" -o tsv`
else
    echo "$RESOURCE_GROUP not found"
fi

echo "Registry: $ACR_NAME | Cluster: $CLUSTER_NAME | Key Vault: $KV_NAME"

if [ -z "$ACR_NAME" ] || [ -z "$CLUSTER_NAME" ] || [ -z "$KV_NAME" ];
then
    exit 1
fi

if [ "$1" == "build" ];
then
  az acr build -r $ACR_NAME -g $RESOURCE_GROUP \
      -t $APP_NAME:$REVISION -t $APP_NAME:latest .

  IMAGE=$ACR_LOGINSERVER/$APP_NAME:$REVISION
else
  IMAGE=$ACR_LOGINSERVER/$APP_NAME:latest
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
EOF

cat <<EOF | kubectl apply -f -
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentityBinding
metadata:
  name: ${KV_CONSUMER_NAME}-binding
  namespace: ${NAMESPACE}
spec:
  azureIdentity: ${KV_CONSUMER_NAME}
  selector: ${KV_CONSUMER_NAME}
---
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: ${KV_CONSUMER_NAME}
  namespace: ${NAMESPACE}
spec:
  type: 0
  resourceID: ${KV_CONSUMER_ID}
  clientID: ${KV_CONSUMER_CLIENT_ID}
---
kind: Service
apiVersion: v1
metadata:
  name: simple-js
  namespace: ${NAMESPACE}
  labels:
    app: simple-js
spec:
  selector:
    app: simple-js
  ports:
    - port: 5001
  type: LoadBalancer
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: simple-js
  namespace: ${NAMESPACE}
  labels:
    app: simple-js
spec:
  replicas: 1
  selector:
    matchLabels:
      app: simple-js
  template:
    metadata:
      labels:
        app: simple-js
        aadpodidbinding: ${KV_CONSUMER_NAME}
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "simple-js"
        dapr.io/app-port: "5001"
    spec:
      containers:
      - name: simple-js
        image: ${IMAGE}
        ports:
        - containerPort: 5001
---
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: secretstore
  namespace: ${NAMESPACE}
spec:
  type: secretstores.azure.keyvault
  version: v1
  metadata:
  - name: vaultName
    value: ${KV_FQDN}
EOF
