#!/bin/bash

set -e

APP_NAME=${PWD##*/}
REVISION=`date +"%s"`
NAMESPACE=dip
SECRET=`echo -n "the-answer-is-42" | base64`
REGISTRY=localhost:5501

if [ "$1" == "build" ]; then
  docker build -t $REGISTRY/$APP_NAME:latest .
  docker push $REGISTRY/$APP_NAME:latest
fi
IMAGE=$REGISTRY/$APP_NAME:latest

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${NAMESPACE}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: kube-system-cluster-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: ${NAMESPACE}
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
    spec:
      containers:
      - name: ${APP_NAME}
        image: localhost:5000/${APP_NAME}
        imagePullPolicy: Always
        ports:
        - containerPort: 5001
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
apiVersion: v1
kind: Secret
metadata:  
  name: ${APP_NAME}-secret
  namespace: ${NAMESPACE}
type: Opaque
data:
  value: ${SECRET}
---
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: secretstore
  namespace: ${NAMESPACE}
spec:
  type: secretstores.kubernetes
  version: v1
  metadata: []
EOF
