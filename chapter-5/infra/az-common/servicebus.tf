resource "azurerm_servicebus_namespace" "sb" {
  name                = "${var.resource_prefix}sb"
  resource_group_name = var.resource_group
  location            = var.location
  tags                = var.tags

  sku = "Standard"
}
