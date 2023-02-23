resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.resource_prefix}-log"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku               = "PerGB2018"
  retention_in_days = 30
}
