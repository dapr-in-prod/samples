# Installing and Managing Dapr

## sample combinations

Folder **chapter-2** supports these combinations of samples to be deployed:

| combination | deployment steps |
| ---- | ---- |
| Azure Container Apps - simple secret store access | 1. `cd {repository-root}/chapter-2/infra/aca-terraform`<br/>2. `../scripts/az-tfstate.sh {location}`<br/>3. adapt `terraform.tfvars` with desired values<br/>4. `terraform apply --auto-approve`<br/>5. `cd {repository-root}/chapter-2/apps/simple-js`<br/>6. `./aca-deploy.sh build` |
| Azure Kubernetes Service with External IP on application - simple secret store access | 1. `cd {repository-root}/chapter-2/infra/aks-terraform`<br/>2. `../scripts/az-tfstate.sh {location}`<br/>3. adapt `terraform.tfvars` with desired values (be sure to have `dapr_deploy = true` set to get Dapr installed with Helm/Terraform already)<br/>4. `terraform apply --auto-approve`<br/>5. `../scripts/aks-getcreds.sh`<br/>6. `cd {repository-root}/chapter-2/apps/simple-js`<br/>7. `./aks-deploy.sh build` |
| Azure Kubernetes Service with Azure Application Gateway ingress (AGIC) - simple secret store access | 1. `cd {repository-root}/chapter-2/infra/aks-agic-terraform`<br/>2. `../scripts/az-tfstate.sh {location}`<br/>3. adapt `terraform.tfvars` with desired values (be sure to have `dapr_deploy = true` set to get Dapr installed with Helm/Terraform already)<br/>4. `terraform apply --auto-approve`<br/>5. `../scripts/aks-getcreds.sh`<br/>6. `cd {repository-root}/chapter-2/apps/simple-js`<br/>7. `./aks-agic-deploy.sh build` |

> for all AKS cases, from the respective infrastructure sample folder, `source ../scripts/set-aliases.sh` can be used to set up some aliases for the `kubectl` commands

## check scaling


let cid = ContainerInventory
| where Name startswith "k8s_dapr-sidecar-injector"
| summarize by ContainerID;
ContainerLog
| where ContainerID in (cid)
| where TimeGenerated >= ago(30m)
| where LogEntry has "Sidecar injector succeeded injection for app 'stateless-scaling-js'"
| summarize count() by bin(TimeGenerated, 1m)
| render columnchart 

let cid = ContainerInventory
| where Name startswith "k8s_dapr-sidecar-injector"
| summarize by ContainerID;
ContainerLog
| where ContainerID in (cid)
| where TimeGenerated >= ago(30m)
| where LogEntry has "Sidecar injector succeeded injection for app 'stateless-scaling-js'"
| order by TimeGenerated desc


source $CODESPACE_VSCODE_FOLDER/chapter-2/infra/scripts/set-aliases.sh

helm uninstall dapr --namespace dapr-system
kubectl delete ns dapr-system
helm upgrade --install dapr dapr/dapr --version=1.9.5 --wait --namespace dapr-system --create-namespace --values ./helm-values.yaml

helm upgrade --install dapr dapr/dapr --version=1.9.4 --namespace dapr-system --create-namespace --set global.ha.enabled=true --wait



helm upgrade dapr dapr/dapr --version=1.9.5 --wait --namespace dapr-system --values ./helm-values.yaml

helm upgrade dapr dapr/dapr --version=1.9.5 --namespace dapr-system --reuse-values --wait

helm upgrade dapr dapr/dapr --version=1.9.5 --namespace dapr-system --set global.ha.enabled=true --wait

kda delete statefulset.apps/dapr-placement-server
helm upgrade dapr dapr/dapr --version=1.9.5 --wait --namespace dapr-system --set global.ha.enabled=true,dapr_sidecar_injector.logLevel=debug


helm upgrade dapr dapr/dapr --version=1.9.5 --wait --namespace dapr-system --reuse-values --set dapr_sidecar_injector.logLevel=error

kd rollout restart deployment stateless-scaling-js
kd delete horizontalpodautoscaler.autoscaling/stateless-scaling-js

kd scale deployment stateless-scaling-js --replicas 30