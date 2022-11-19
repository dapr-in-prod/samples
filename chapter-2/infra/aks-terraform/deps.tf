resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroup
  location = var.location
  tags     = local.tags
}

module "common" {
  source         = "../../../common/az-modules"
  resourcePrefix = var.resourcePrefix
  resourceGroup  = azurerm_resource_group.rg.name
  location       = azurerm_resource_group.rg.location
  tags           = local.tags
}
