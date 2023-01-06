#!/bin/bash

minikube config set vm-driver docker
minikube start --cpus=4 --memory=4096

if [ "$1" == "build" ];
then
    minikube addons enable metrics-server
    minikube addons enable dashboard
    minikube addons enable ingress
    dapr init -k
fi