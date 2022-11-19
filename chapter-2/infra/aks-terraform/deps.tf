resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.location
  tags     = local.tags
}

module "common" {
  source         = "../../../common/az-deps"
  resource_prefix = var.resource_prefix
  resource_group  = azurerm_resource_group.rg.name
  location       = azurerm_resource_group.rg.location
  tags           = local.tags
}
