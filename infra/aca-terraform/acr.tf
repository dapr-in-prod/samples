resource "random_string" "acrsuffix" {
  length = 10
  special = false
  upper = false
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.resourcePrefix}${random_string.acrsuffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
}