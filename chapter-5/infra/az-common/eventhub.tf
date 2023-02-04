resource "azurerm_eventhub_namespace" "eh" {
  name                = "${var.resource_prefix}-eh"
  resource_group_name = var.resource_group
  location            = var.location
  tags                = var.tags

  sku      = "Standard"
  capacity = 1
}
