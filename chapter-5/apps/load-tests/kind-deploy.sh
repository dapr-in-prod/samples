#!/bin/bash

set -e

APP_NAME_SENDER=sender
APP_NAME_RECEIVER=receiver
REVISION=`date +"%s"`
NAMESPACE=dip
REGISTRY=localhost:5000

if [ "$1" == "build" ]; then
  docker build -t $REGISTRY/$APP_NAME_SENDER:latest $APP_NAME_SENDER/
  docker build -t $REGISTRY/$APP_NAME_RECEIVER:latest $APP_NAME_RECEIVER/
  docker push $REGISTRY/$APP_NAME_SENDER:latest
  docker push $REGISTRY/$APP_NAME_RECEIVER:latest
fi
IMAGE_SENDER=$REGISTRY/$APP_NAME_SENDER:latest
IMAGE_RECEIVER=$REGISTRY/$APP_NAME_RECEIVER:latest

# deploy application
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
  name: ${APP_NAME_SENDER}
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME_SENDER}
spec:
  selector:
    app: ${APP_NAME_SENDER}
  ports:
    - port: 5001
  type: NodePort
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${APP_NAME_SENDER}
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME_SENDER}
  annotations:
    ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    ingress.kubernetes.io/rewrite-target: /
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
           name: ${APP_NAME_SENDER}
           port:
             number: 5001
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: ${APP_NAME_SENDER}
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME_SENDER}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APP_NAME_SENDER}
  template:
    metadata:
      labels:
        app: ${APP_NAME_SENDER}
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "${APP_NAME_SENDER}"
        dapr.io/app-port: "5001"
    spec:
      containers:
      - name: ${APP_NAME_SENDER}
        image: localhost:5000/${APP_NAME_SENDER}
        imagePullPolicy: Always
        ports:
        - containerPort: 5001
        livenessProbe:
          httpGet:
            path: /health
            port: 5001
        readinessProbe:
          httpGet:
            path: /health
            port: 5001
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: ${APP_NAME_RECEIVER}
  namespace: ${NAMESPACE}
  labels:
    app: ${APP_NAME_RECEIVER}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APP_NAME_RECEIVER}
  template:
    metadata:
      labels:
        app: ${APP_NAME_RECEIVER}
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "${APP_NAME_RECEIVER}"
        dapr.io/app-port: "5002"
    spec:
      containers:
      - name: ${APP_NAME_RECEIVER}
        image: localhost:5000/${APP_NAME_RECEIVER}
        imagePullPolicy: Always
        ports:
        - containerPort: 5002
        livenessProbe:
          httpGet:
            path: /health
            port: 5002
        readinessProbe:
          httpGet:
            path: /health
            port: 5002
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: pubsub-loadtest
  namespace: ${NAMESPACE}
spec:
  type: pubsub.redis
  version: v1
  metadata:
  - name: redisHost
    value: localhost:6379
  - name: redisPassword
    value: ""
EOF

# check
sleep 10
kubectl wait --namespace=$NAMESPACE --selector=app=$APP_NAME_SENDER --for=condition=ready pod
kubectl wait --namespace=$NAMESPACE --selector=app=$APP_NAME_RECEIVER --for=condition=ready pod
curl http://localhost/health

