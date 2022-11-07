resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroup
  location = var.location
  tags     = local.tags
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-aca"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = local.tags
}

resource "azurerm_application_insights" "ai" {
  name                = "ai-aca"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "web"

  retention_in_days = 30
  workspace_id      = azurerm_log_analytics_workspace.log.id

  tags = local.tags
}
