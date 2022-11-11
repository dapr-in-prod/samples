# Dapr-in-Production examples

> STATUS : **UNDER CONSTRUCTION**

## Repository structure

Main folders represent deployment layers 

- `infra` : contains infrastructure (cloud) resources which are required to host samples applications
- `apps` : sample applications

## Prequisites

### Azure

To use Azure examples in this repository these tools are required:

- Azure CLI version >= `2.42.0`

Before starting deployments, optionally execute these steps 

- `az login` to your Azure account and set the desired subscription with `az account set -s {subscription-id}`
- create a service principal e.g. with `az ad sp create-for-rbac --name "My Terraform Service Principal" --role="Contributor" --scopes="/subscriptions/$(az account show --query id -o tsv)"` to create and assign `Contributor` authorizations on the subscription currently set in Azure CLI
- from the output like

```
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "My Terraform Service Principal",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

note down, create a script or extend your session initialization script like `.bashr` or `.zshrc` to set Terraform environment variables: 

```shell
export ARM_SUBSCRIPTION_ID="{subscription-id}"
export ARM_TENANT_ID="{tenant}"
export ARM_CLIENT_ID="{appId}"
export ARM_CLIENT_SECRET="{password}"
```

- assign RBAC management authorization to service principal with `az role assignment create --role 'Role Based Access Control Administrator (Preview)' --scope /subscriptions/$ARM_SUBSCRIPTION_ID --assignee $ARM_CLIENT_ID` so that various role assignments can be conducted by Terraform

### Terraform

All infrastructure in this repository is defined with [Terraform templates](https://www.terraform.io/) which requires these tools:

- Terraform CLI version >= `1.3.2`

## Example deployments

### deployment on Azure with Terraform

> review and install Azure and Terraform prerequisites

1. change into the folder of the desired sample e.g. `cd ./infra/aca-terraform`
1. be sure to clear previous state with `rm .terraform.lock.hcl` and `rm -rf .terraform` 
1. configure state store and initialize e.g. with Azure storage `../scripts/az-tfstate.sh {location}` where _location_ sets the region, where the statestore is placed (otherwise eastus will be used as a default)
1. create `terraform.tfvars` to define desired resource group and location/region

```terraform
location      = "westus"
resourceGroup = "rg-dip-aca"
```

4. review deployment plan with `terraform plan`
1. deploy with `terraform apply`
