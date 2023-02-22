resource "azurerm_load_test" "loadtest" {
  name                = "${var.resource_prefix}-lt"
  resource_group_name = var.rg_name
  location            = var.location
  tags                = var.tags
}
