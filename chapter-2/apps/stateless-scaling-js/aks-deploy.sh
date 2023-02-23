#!/bin/bash

set -e

TARGET_INFRA_FOLDER=../../infra/aks-terraform
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

if [ ! $(az group exists --name $RESOURCE_GROUP) = true ];
then
    echo "$RESOURCE_GROUP not found"
fi

if [ -z "$ACR_NAME" ] || [ -z "$CLUSTER_NAME" ];
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
  type: LoadBalancer
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
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "${APP_NAME}"
        dapr.io/app-port: "5001"
        dapr.io/sidecar-cpu-limit: "200m"
        dapr.io/sidecar-cpu-request: "100m"
        dapr.io/sidecar-memory-limit: "500Mi"
        dapr.io/sidecar-memory-request: "250Mi"
    spec:
      containers:
      - name: ${APP_NAME}
        image: ${IMAGE}
        ports:
        - containerPort: 5001
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
kind: HorizontalPodAutoscaler
apiVersion: autoscaling/v2
metadata:
  name: ${APP_NAME}
  namespace: ${NAMESPACE}
spec:
  minReplicas: 1
  maxReplicas: 10
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ${APP_NAME}
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 20
EOF

# output the URL
kubectl wait --selector=app=$APP_NAME --for=condition=ready pod --namespace=$NAMESPACE
IP=`kubectl get svc $APP_NAME -o jsonpath="{.status.loadBalancer.ingress[0].ip}" --namespace $NAMESPACE`
PORT=`kubectl get svc $APP_NAME -o jsonpath="{.spec.ports[0].targetPort}" --namespace $NAMESPACE`
echo "Single test URL: curl http://$IP:$PORT/calculate"
echo -e "Scaling test URL: kubectl run --namespace $NAMESPACE -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c \x22while sleep 0.01; do wget -q -O- http://$IP:$PORT/calculate; done\x22"
