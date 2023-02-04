# Dapr-in-Production examples

> STATUS : **UNDER CONSTRUCTION**

## Repository structure

Main folders represent chapters in book, `common` contains Terraform modules and Bash scripts used commonly

- `chapter-2` : Installing and Managing Dapr

Sub folders in main folders represent deployment layers

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

```json
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "My Terraform Service Principal",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

- note down, create a script or extend your session initialization script like `.bashr` or `.zshrc` to set Terraform environment variables:

```shell
export ARM_SUBSCRIPTION_ID="{subscription-id}"
export ARM_TENANT_ID="{tenant}"
export ARM_CLIENT_ID="{appId}"
export ARM_CLIENT_SECRET="{password}"
```

- or when running these samples with **GitHub Codespaces**, add 4 secrets `ARM_SUBSCRIPTION_ID`, `ARM_TENANT_ID`, `ARM_CLIENT_ID`, `ARM_CLIENT_SECRET` and assign those to this repository or the fork of the repository you are using
- assign RBAC management authorization to service principal with `az role assignment create --role 'Role Based Access Control Administrator (Preview)' --scope /subscriptions/$ARM_SUBSCRIPTION_ID --assignee $ARM_CLIENT_ID` so that various role assignments can be conducted by Terraform
- if you want to sign in with the above credentils to your current Azure CLI session, use `az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID && az account set -s $ARM_SUBSCRIPTION_ID`

### Terraform & Helm

All infrastructure in this repository is defined with [Terraform templates](https://www.terraform.io/) with linked [Helm charts](https://helm.sh/) which requires these tools:

- Terraform CLI version >= `1.3.2`
- Helm CLI version >= `3.9.4`
- jq version >= `1.6`

optional:

- [terraform-docs](https://terraform-docs.io/user-guide/installation/) >= `0.16.0` 

### Kind - Kubernetes in Docker

To explore samples in this repository, also a [**Kind local cluster**](https://registry.terraform.io/providers/kyma-incubator/kind/latest/docs/resources/cluster) configuration can be used.

If not yet existing, create empty **kubectl** configuration file:

```shell
mkdir ~/.kube
touch ~/.kube/config
```

then deploy **Kind**:

```shell
cd ./chapter-2/infra/local-terraform
terraform init
terraform apply
````

### Sample Apps

This section lists all (local) requirements for the particular sample applications:

#### simple-js

- Node.js v16
- Azure CLI Container Apps extension - install with `az extension add -n containerapp`

----

## Example deployments

This section describes how to generally deploy infrastructure and sample applications. See here for [all sample deployment combinations](./chapter-2/README.md)

### deployment on Azure with Terraform

#### Infrastructure

> review and install Azure, Terraform and Helm prerequisites

1. change into the folder of the desired sample e.g. `cd ./chapter-2/infra/aca-terraform`
1. be sure to clear previous state with `rm .terraform.lock.hcl` and `rm -rf .terraform`
1. configure state store and initialize e.g. with Azure storage `$(git rev-parse --show-toplevel)/common/scripts/az-tfstate.sh {location}` where _location_ sets the region, where the state store is placed (otherwise eastus will be used as a default)
1. create `terraform.tfvars` to define desired resource group and location/region or generate with `terraform-docs tfvars hcl . >./terraform.tfvars`

```terraform
location                 = "westus"
resource_group           = "rg-dip-aca"
resource_prefix          = "dipaca"
purge_protection_enabled = false
secretstore_admins       = ["00000000-0000-0000-0000-000000000000"]
```
<!-- markdownlint-disable-next-line MD029 -->
4. review deployment plan with `terraform plan`
1. deploy with `terraform apply`

#### Apps

1. change into the folder of the desired sample e.g. `cd ./chapter-2/apps/simple-js`
1. build and deploy to Container Apps with `../scripts/aca-deploy.sh build` (and `../scripts/aca-deploy.sh` when you want to deploy the container from container registry w/o rebuilding)

----

## Helpers

### set Terraform Azure Storage State backend

`cd` to the folder which holds the Terraform modules e.g. `cd ./chapter-2/infra/aks-terraform` and then:

```shell
$(git rev-parse --show-toplevel)/common/scripts/az-tfstate.sh {location}
```

### remove local Terraform state

from repository main folder

```shell
find . -name .terraform* -type d | xargs -i rm -rf {}
find . -name .terraform* -type f
```

