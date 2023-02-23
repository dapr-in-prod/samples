locals {
  tags = {
    "project" = "dapr-in-prod"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
  tags     = local.tags
}

module "loganalytics" {
  source          = "../../../modules/az/loganalytics"
  location        = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  tags            = local.tags
  resource_prefix = var.resource_prefix
}

module "keyvault" {
  source                     = "../../../modules/az/keyvault"
  location                   = var.location
  resource_group_name                    = azurerm_resource_group.rg.name
  tags                       = local.tags
  resource_prefix            = var.resource_prefix
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days
  secretstore_admins         = var.secretstore_admins
}

module "aca" {
  source                    = "../../../modules/az/aca"
  location                  = var.location
  resource_group_name                   = azurerm_resource_group.rg.name
  tags                      = local.tags
  resource_prefix           = var.resource_prefix
  loganalytics_id           = module.loganalytics.LOGANALYTICS_ID
  keyvault_name             = module.keyvault.KEYVAULT_NAME
  kv_consumer_client_id     = module.keyvault.KEYVAULT_CONSUMER_CLIENT_ID
}

module "acr" {
  source          = "../../../modules/az/acr"
  location        = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  tags            = local.tags
  resource_prefix = var.resource_prefix
}
