

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
https://registry.terraform.io/providers/Azure/azapi/latest/docs


az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$(az account show --query id -o tsv)" --name "My Terraform Service Principal"


## create Terraform state in Azure Storage

```shell
../scripts/az-tfstate.sh
```