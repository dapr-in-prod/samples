# Installing and Managing Dapr

## sample combinations

Folder **chapter-2** supports these combinations of samples to be deployed:

| combination | deployment steps |
| ---- | ---- |
| Azure Container Apps - simple secret store access | 1. `cd {repository-root}/chapter-2/infra/aca-terraform`<br/>2. `../scripts/az-tfstate.sh {location}`<br/>3. adapt `terraform.tfvars` with desired values<br/>4. `terraform apply --auto-approve`<br/>5. `cd {repository-root}/chapter-2/apps/simple-js`<br/>6. `./aca-deploy.sh build` |
| Azure Kubernetes Service with External IP on application - simple secret store access | 1. `cd {repository-root}/chapter-2/infra/aks-terraform`<br/>2. `../scripts/az-tfstate.sh {location}`<br/>3. adapt `terraform.tfvars` with desired values (be sure to have `dapr_deploy = true` set to get Dapr installed with Helm/Terraform already)<br/>4. `terraform apply --auto-approve`<br/>5. `../scripts/aks-getcreds.sh`<br/>6. `cd {repository-root}/chapter-2/apps/simple-js`<br/>7. `./aks-deploy.sh build` |
| Azure Kubernetes Service with Azure Application Gateway ingress (AGIC) - simple secret store access | 1. `cd {repository-root}/chapter-2/infra/aks-agic-terraform`<br/>2. `../scripts/az-tfstate.sh {location}`<br/>3. adapt `terraform.tfvars` with desired values (be sure to have `dapr_deploy = true` set to get Dapr installed with Helm/Terraform already)<br/>4. `terraform apply --auto-approve`<br/>5. `../scripts/aks-getcreds.sh`<br/>6. `cd {repository-root}/chapter-2/apps/simple-js`<br/>7. `./aks-agic-deploy.sh build` |
| Minikube - simple secret store access | 1. `cd {repository-root}/chapter-2/infra/scripts`<br/>2. `./minikube-start.sh init`<br/>3. `cd {repository-root}/chapter-2/apps/simple-js`<br/>4. `./minikube-deploy.sh build` |

> for all AKS cases, from the respective infrastructure sample folder, `source ../scripts/set-aliases.sh` can be used to set up some aliases for the `kubectl` commands
