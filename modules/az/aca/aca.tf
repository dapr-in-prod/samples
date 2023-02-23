resource "azurerm_container_app_environment" "aca_env" {
  name                = "${var.resource_prefix}-aca"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  log_analytics_workspace_id = var.loganalytics_id
}
