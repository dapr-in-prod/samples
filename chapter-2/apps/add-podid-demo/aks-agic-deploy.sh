#!/bin/bash

set -e

TARGET_INFRA_FOLDER=../../infra/aks-agic-terraform
APP_NAME=demo
NAMESPACE=aad-podid
SUBSCRIPTION_ID=`az account show --query id -o tsv`

source <(terraform -chdir=$TARGET_INFRA_FOLDER output --json | jq -r 'keys[] as $k | "\($k|ascii_upcase)=\(.[$k] | .value)"')

echo "App Id + Image: $APP_NAME"
echo "Resource Group: $RESOURCE_GROUP"
echo "Cluster: $CLUSTER_NAME"
echo "Identity Name:" $KV_CONSUMER_NAME
echo "           Id:"$KV_CONSUMER_ID
echo "    Client Id:" $KV_CONSUMER_CLIENT_ID

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
EOF

cat << EOF | kubectl apply -f -
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
apiVersion: v1
kind: Pod
metadata:
  name: demo
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME}    
    aadpodidbinding: ${KV_CONSUMER_NAME}
spec:
  containers:
  - name: demo
    image: mcr.microsoft.com/oss/azure/aad-pod-identity/demo:v1.8.14
    args:
      - --subscription-id=${SUBSCRIPTION_ID}
      - --resource-group=${RESOURCE_GROUP}
      - --identity-client-id=${KV_CONSUMER_CLIENT_ID}
  nodeSelector:
    kubernetes.io/os: linux
EOF

kubectl wait --namespace=$NAMESPACE --selector=app=$APP_NAME --for=condition=ready pod
sleep 1m
kubectl logs $APP_NAME --namespace $NAMESPACE
