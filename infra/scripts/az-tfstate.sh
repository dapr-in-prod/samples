#!/bin/bash

RESOURCE_GROUP_NAME=tfstate
STORAGE_ACCOUNT_NAME=tfstate$RANDOM
CONTAINER_NAME=tfstate
LOCATION=eastus

# Create resource group
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

# Create storage account
az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME

ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)

terraform init \
-backend-config="resource_group_name=$RESOURCE_GROUP_NAME" \
-backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
-backend-config="container_name=$CONTAINER_NAME" \
-backend-config="key=terraform.tfstate" \
-backend-config="access_key=$ACCOUNT_KEY"