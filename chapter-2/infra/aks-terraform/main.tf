locals {
  tags = {
    "project" = "dapr-in-prod"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
  tags     = var.tags
}

module "loganalytics" {
  source              = "../../../modules/az/loganalytics"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  resource_prefix     = var.resource_prefix
}

module "keyvault" {
  source                     = "../../../modules/az/keyvault"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  tags                       = var.tags
  resource_prefix            = var.resource_prefix
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days
  secretstore_admins         = var.secretstore_admins
}

module "aks" {
  source              = "../../../modules/az/aks"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  resource_prefix     = var.resource_prefix
  cluster_admins      = var.cluster_admins
  loganalytics_id     = module.loganalytics.LOGANALYTICS_ID
  loganalytics_name   = module.loganalytics.LOGANALYTICS_NAME
  acr_id              = module.acr.CONTAINER_REGISTRY_ID
}

module "acr" {
  source              = "../../../modules/az/acr"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
  resource_prefix     = var.resource_prefix
}

module "aad_pod_identity" {
  source              = "../../../modules/az/aad_pod_identity"
  resource_group_id   = azurerm_resource_group.rg.id
  resource_group_name = azurerm_resource_group.rg.name
  cluster_id          = module.aks.CLUSTER_ID
  cluster_name        = module.aks.CLUSTER_NAME
  node_resource_group = module.aks.NODE_RESOURCE_GROUP
  providers = {
    helm = helm
  }
  depends_on = [
    module.aks
  ]
}

module "dapr" {
  count               = var.dapr_deploy ? 1 : 0
  source              = "../../../modules/az/dapr"
  resource_group_name = azurerm_resource_group.rg.name
  cluster_name        = module.aks.CLUSTER_NAME
  dapr_namespace      = var.dapr_namespace
  dapr_version        = var.dapr_version
  providers = {
    helm = helm
  }
  depends_on = [
    module.aks
  ]
}
