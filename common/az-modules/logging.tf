resource "azurerm_log_analytics_workspace" "log" {
  name                = "${var.resourcePrefix}-log"
  resource_group_name = var.resourceGroup
  location            = var.location

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = var.tags
}

resource "azurerm_application_insights" "ai" {
  name                = "${var.resourcePrefix}-ai"
  resource_group_name = var.resourceGroup
  location            = var.location
  application_type    = "web"

  retention_in_days = 30
  workspace_id      = azurerm_log_analytics_workspace.log.id

  tags = var.tags
}
