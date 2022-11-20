#!/bin/bash

TARGET=../../infra/aks-terraform
TFVARS=$TARGET/terraform.tfvars
APPNAME=${PWD##*/}
REVISION=`date +"%s"`
NAMESPACE=dip

source <(sed 's/\s//g' $TFVARS)

echo -e "App Id + Image: $APPNAME\nResource Group: $resource_group"

if [ $(az group exists --name $resource_group) = true ];
then
    ACRNAME=`az acr list -g $resource_group --query [0].name -o tsv`
    ACRLOGINSERVER=`az acr list -g $resource_group --query [0].loginServer -o tsv`
    AKSNAME=`az aks list -g $resource_group --query [0].name -o tsv`
    KVCONSUMERID=`az identity list -g $resource_group --query "[?contains(name,'kvconsumer')].id" -o tsv`
else
    echo "$resource_group not found"
fi

echo "Registry: $ACRNAME | Cluster: $AKSNAME"

if [ -z "$ACRNAME" ] || [ -z "$AKSNAME" ];
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
      containers:
      - name: simple-js
        image: ${IMAGE}
        ports:
        - containerPort: 5001
EOF
