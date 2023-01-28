# Installing and Managing Dapr

## sample combinations

Folder **chapter-2** supports these combinations of samples to be deployed:

| combination | deployment steps |
| ---- | ---- |
| Azure Container Apps - simple secret store access | 1. `cd {repository-root}/chapter-2/infra/aca-terraform`<br/>2. `../scripts/az-tfstate.sh {location}`<br/>3. adapt `terraform.tfvars` with desired values<br/>4. `terraform apply --auto-approve`<br/>5. `cd {repository-root}/chapter-2/apps/simple-js`<br/>6. `./aca-deploy.sh build` |
| Azure Kubernetes Service with External IP on application - simple secret store access | 1. `cd {repository-root}/chapter-2/infra/aks-terraform`<br/>2. `../scripts/az-tfstate.sh {location}`<br/>3. adapt `terraform.tfvars` with desired values (be sure to have `dapr_deploy = true` set to get Dapr installed with Helm/Terraform already)<br/>4. `terraform apply --auto-approve`<br/>5. `../scripts/aks-getcreds.sh`<br/>6. `cd {repository-root}/chapter-2/apps/simple-js`<br/>7. `./aks-deploy.sh build` |
| Azure Kubernetes Service with Azure Application Gateway ingress (AGIC) - simple secret store access | 1. `cd {repository-root}/chapter-2/infra/aks-agic-terraform`<br/>2. `../scripts/az-tfstate.sh {location}`<br/>3. adapt `terraform.tfvars` with desired values (be sure to have `dapr_deploy = true` set to get Dapr installed with Helm/Terraform already)<br/>4. `terraform apply --auto-approve`<br/>5. `../scripts/aks-getcreds.sh`<br/>6. `cd {repository-root}/chapter-2/apps/simple-js`<br/>7. `./aks-agic-deploy.sh build` |
| Kind - simple secret store access | 1. `cd {repository-root}/chapter-2/infra/local-terraform`<br/>2. adapt `terraform.tfvars` with desired values (be sure to have `dapr_deploy = true` set to get Dapr installed with Helm/Terraform already)<br/>3. `terraform apply --auto-approve`<br/>4. `cd {repository-root}/chapter-2/apps/simple-js`<br/>5. `./kind-deploy.sh build` |

> for all AKS cases, from the respective infrastructure sample folder, `source ../scripts/set-aliases.sh` can be used to set up some aliases for the `kubectl` commands

## helpers

### set `kubectl` aliases

```shell
source $(git rev-parse --show-toplevel)/chapter-2/infra/scripts/set-aliases.sh
```


kubectl auth can-i get secrets \
	--namespace dip \
	--as system:serviceaccount:dip:default