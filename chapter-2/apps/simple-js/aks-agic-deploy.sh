#!/bin/bash

set -e

TARGET_INFRA_FOLDER=../../infra/aks-agic-terraform
APP_NAME=${PWD##*/}
REVISION=`date +"%s"`
NAMESPACE=dip
AAD_IDENTITY_NAME=$APP_NAME
SUBSCRIPTION_ID=`az account show --query id -o tsv`

source <(terraform -chdir=$TARGET_INFRA_FOLDER output --json | jq -r 'keys[] as $k | "\($k|ascii_upcase)=\(.[$k] | .value)"')

echo "App Id + Image: $APP_NAME"
echo "Resource Group: $RESOURCE_GROUP"
echo "Registry: $ACR_NAME"
echo "Cluster: $CLUSTER_NAME"
echo "Key Vault: $KV_NAME"

if [ ! $(az group exists --name $RESOURCE_GROUP) = true ];
then
    echo "$RESOURCE_GROUP not found"
fi

KV_FQDN=`az keyvault show -g $RESOURCE_GROUP -n $KV_NAME --query properties.vaultUri -o tsv | sed -e 's|^[^/]*//||' -e 's|/.*$||'`

if [ -z "$ACR_NAME" ] || [ -z "$CLUSTER_NAME" ] || [ -z "$KV_NAME" ];
then
    exit 1
fi

if [ "$1" == "build" ];
then
  az acr build -r $ACR_NAME -g $RESOURCE_GROUP \
      -t $APP_NAME:$REVISION -t $APP_NAME:latest .
        IMAGE=$ACR_LOGIN_SERVER/$APP_NAME:$REVISION
else
  TAG=`az acr repository show-tags -n $ACR_NAME --repository $APP_NAME --top 1 --orderby time_desc -o tsv`
  IMAGE=$ACR_LOGIN_SERVER/$APP_NAME:$TAG
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
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}
spec:
  selector:
    app: ${APP_NAME}
  ports:
  - port: 5001
    targetPort: 5001
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
    appgw.ingress.kubernetes.io/override-frontend-port: "${GATEWAY_FRONTEND_PORT}"
    appgw.ingress.kubernetes.io/health-probe-path: "/health"
spec:
  rules:
  - http:
      paths:
      - path: /*
        backend:
          service:
            name: ${APP_NAME}
            port:
              number: 5001
        pathType: Exact
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APP_NAME}
  template:
    metadata:
      labels:
        app: ${APP_NAME}
        aadpodidbinding: ${KV_CONSUMER_NAME}
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: ${APP_NAME}
        dapr.io/app-port: "5001"
    spec:
      containers:
      - name: ${APP_NAME}
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

kubectl wait --selector=app=$APP_NAME --for=condition=ready pod --namespace=$NAMESPACE
echo "Health URL: curl http://$GATEWAY_PUBLIC_IP:$GATEWAY_FRONTEND_PORT/health"
