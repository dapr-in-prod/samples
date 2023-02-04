resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
  tags     = local.tags
}

module "common" {
  source                     = "../../../common/az-deps"
  resource_prefix            = var.resource_prefix
  resource_group             = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  tags                       = local.tags
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days
  secretstore_admins         = var.secretstore_admins
}

module "az-common" {
  source                     = "../az-common"
  resource_prefix            = var.resource_prefix
  resource_group             = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  tags                       = local.tags
}
