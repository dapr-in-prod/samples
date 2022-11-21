#!/bin/bash

# https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity?source=recommendations
# https://github.com/Azure-Samples/azure-workload-identity-nodejs-aks-terraform/tree/main/Infra
# https://azure.github.io/azure-workload-identity/docs/installation/mutating-admission-webhook.html

set -e

TARGET=../../infra/aks-terraform
TFVARS=$TARGET/terraform.tfvars
APPNAME=${PWD##*/}
REVISION=`date +"%s"`
NAMESPACE=dip

SERVICE_ACCOUNT_NAME="workload-identity-sa"
# user assigned identity name
export UAID="fic-kv-ua"
# federated identity name
export FICID="fic-kv-fic-name" 

source <(sed 's/\s//g' $TFVARS)

echo -e "App Id + Image: $APPNAME\nResource Group: $resource_group"

if [ $(az feature show --namespace Microsoft.ContainerService -n EnableOIDCIssuerPreview --query properties.state -o tsv) != "Registered" ];
then
  echo "EnableOIDCIssuerPreview not registered"
  exit 1
fi

# if [ $(az feature show --namespace Microsoft.ContainerService -n EnableWorkloadIdentityPreview --query properties.state -o tsv) != "Registered" ];
# then
#   echo "EnableWorkloadIdentityPreview not registered"
#   exit 1
# fi

if [ $(az group exists --name $resource_group) = true ];
then
    ACRNAME=`az acr list -g $resource_group --query [0].name -o tsv`
    ACRLOGINSERVER=`az acr list -g $resource_group --query [0].loginServer -o tsv`
    AKSNAME=`az aks list -g $resource_group --query [0].name -o tsv`
    AKS_OIDC_ISSUER="$(az aks show -n $AKSNAME -g $resource_group --query "oidcIssuerProfile.issuerUrl" -o tsv)"
    KVNAME=`az keyvault list -g $resource_group --query [0].name -o tsv`
    KVURL=`az keyvault show -g $resource_group -n $KVNAME --query properties.vaultUri -o tsv`
    UAID=`az identity list -g $resource_group --query "[?contains(name,'kvconsumer')].name" -o tsv`
    KVCONSUMERCLIENTID=`az identity list -g $resource_group --query "[?contains(name,'kvconsumer')].clientId" -o tsv`
else
    echo "$resource_group not found"
fi

echo "Registry: $ACRNAME | Cluster: $AKSNAME | Key Vault: $KVNAME"

if [ -z "$ACRNAME" ] || [ -z "$AKSNAME" ] || [ -z "$KVNAME" ];
then
    exit 1
fi

if [ "$1" == "build" ];
then
  az acr build -r $ACRNAME -g $resource_group \
      -t $APPNAME:$REVISION -t $APPNAME:latest .

  IMAGE=$ACRLOGINSERVER/$APPNAME:$REVISION
else
  IMAGE=$ACRLOGINSERVER/$APPNAME:latest
fi

if [ $(az identity federated-credential list --identity-name $UAID --resource-group $resource_group --query '[0].name' -o tsv) != "$FICID" ];
then
  az identity federated-credential create --name $FICID \
    --identity-name $UAID --resource-group $resource_group \
    --issuer $AKS_OIDC_ISSUER \
    --subject system:serviceaccount:$NAMESPACE:$SERVICE_ACCOUNT_NAME
fi

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${KVCONSUMERCLIENTID}
  labels:
    azure.workload.identity/use: "true"
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${NAMESPACE}
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
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "simple-js"
        dapr.io/app-port: "5001"
    spec:
      serviceAccountName: ${SERVICE_ACCOUNT_NAME}
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
    value: ${KVNAME}
  - name: spnClientId
    value: ${KVCONSUMERCLIENTID}
EOF

# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: Pod
# metadata:
#   name: quick-start
#   namespace: ${NAMESPACE}
# spec:
#   serviceAccountName: ${SERVICE_ACCOUNT_NAME}
#   containers:
#     - image: ghcr.io/azure/azure-workload-identity/msal-go
#       name: oidc
#       env:
#       - name: KEYVAULT_URL
#         value: ${KVURL}
#       - name: SECRET_NAME
#         value: simple-js-secret
#   nodeSelector:
#     kubernetes.io/os: linux
# EOF