resource "azurerm_load_test" "loadtest" {
  name                = "${var.resource_prefix}-lt"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
