#!/bin/bash

# https://github.com/azuredevcollege/aks/blob/master/dapr-secrets-aad-pod-identity/README.md

set -e

TARGET=../../infra/aks-terraform
TFVARS=$TARGET/terraform.tfvars
APPNAME=${PWD##*/}
REVISION=`date +"%s"`
NAMESPACE=dip
AAD_IDENTITY_NAME=$APPNAME
SUBSCRIPTION_ID=`az account show --query id -o tsv`

source <(sed 's/\s//g' $TFVARS)

echo -e "App Id + Image: $APPNAME\nResource Group: $resource_group"

if [ $(az group exists --name $resource_group) = true ];
then
    ACRNAME=`az acr list -g $resource_group --query [0].name -o tsv`
    ACRLOGINSERVER=`az acr list -g $resource_group --query [0].loginServer -o tsv`
    AKSNAME=`az aks list -g $resource_group --query [0].name -o tsv`
    AKS_OIDC_ISSUER="$(az aks show -n $AKSNAME -g $resource_group --query "oidcIssuerProfile.issuerUrl" -o tsv)"
    KVNAME=`az keyvault list -g $resource_group --query [0].name -o tsv`
    KVFQDN=`az keyvault show -g $resource_group -n $KVNAME --query properties.vaultUri -o tsv | sed -e 's|^[^/]*//||' -e 's|/.*$||'`
    UAID=`az identity list -g $resource_group --query "[?contains(name,'kvconsumer')].name" -o tsv`
    KVCONSUMERNAME=`az identity list -g $resource_group --query "[?contains(name,'kvconsumer')].name" -o tsv`
    KVCONSUMERID=`az identity list -g $resource_group --query "[?contains(name,'kvconsumer')].id" -o tsv`
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
  name: ${KVCONSUMERNAME}-binding
  namespace: ${NAMESPACE}
spec:
  azureIdentity: ${KVCONSUMERNAME}
  selector: ${KVCONSUMERNAME}
---
apiVersion: "aadpodidentity.k8s.io/v1"
kind: AzureIdentity
metadata:
  name: ${KVCONSUMERNAME}
  namespace: ${NAMESPACE}
spec:
  type: 0
  resourceID: ${KVCONSUMERID}
  clientID: ${KVCONSUMERCLIENTID}
---
kind: Service
apiVersion: v1
metadata:
  name: ${APPNAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${APPNAME}
spec:
  selector:
    app: ${APPNAME}
  ports:
  - port: 5001
    targetPort: 5001
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${APPNAME}
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
            name: ${APPNAME}
            port:
              number: 5001
        pathType: Exact
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: ${APPNAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${APPNAME}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APPNAME}
  template:
    metadata:
      labels:
        app: ${APPNAME}
        aadpodidbinding: ${KVCONSUMERNAME}
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "simple-js"
        dapr.io/app-port: "5001"
    spec:
      containers:
      - name: ${APPNAME}
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
    value: ${KVFQDN}
EOF
