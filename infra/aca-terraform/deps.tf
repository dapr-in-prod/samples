resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroup
  location = var.location
  tags     = local.tags
}
