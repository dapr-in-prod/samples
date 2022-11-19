resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.resource_prefix}-log"
  resource_group_name = var.resource_group
  location            = var.location
  tags                = var.tags

  sku               = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_application_insights" "ai" {
  name                = "${var.resource_prefix}-ai"
  resource_group_name = var.resource_group
  location            = var.location
  tags                = var.tags

  application_type  = "web"
  retention_in_days = 30
  workspace_id      = azurerm_log_analytics_workspace.log.id
}
