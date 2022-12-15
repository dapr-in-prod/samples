#!/bin/bash

set -e

TARGET_INFRA_FOLDER=../../infra/aks-terraform
APP_NAME=${PWD##*/}
REVISION=`date +"%s"`
NAMESPACE=dip
AAD_IDENTITY_NAME=$APP_NAME
SUBSCRIPTION_ID=`az account show --query id -o tsv`

source <(terraform -chdir=$TARGET_INFRA_FOLDER output --json | jq -r 'keys[] as $k | "\($k|ascii_upcase)=\(.[$k] | .value)"')

if [ -z $ APP_NAMESPACE ];
then
  NAMESPACE=$APP_NAMESPACE
fi

echo -e "App Id + Image: $APP_NAME\nResource Group: $RESOURCE_GROUP"

if [ $(az group exists --name $RESOURCE_GROUP) = true ];
then
  ACR_NAME=`az acr list -g $RESOURCE_GROUP --query [0].name -o tsv`
  ACR_LOGINSERVER=`az acr list -g $RESOURCE_GROUP --query [0].loginServer -o tsv`
  CLUSTER_NAME=`az aks list -g $RESOURCE_GROUP --query [0].name -o tsv`
  AKS_OIDC_ISSUER="$(az aks show -n $CLUSTER_NAME -g $RESOURCE_GROUP --query "oidcIssuerProfile.issuerUrl" -o tsv)"
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
    appgw.ingress.kubernetes.io/override-frontend-port: "8080"
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
        dapr.io/app-id: "simple-js"
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
