resource "azapi_resource" "aca_env" {
  type      = "Microsoft.App/managedEnvironments@2022-06-01-preview"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  name      = var.resourcePrefix
  tags      = local.tags

  body = jsonencode({
    properties = {
      "appLogsConfiguration" : {
        "destination" : "log-analytics"
        "logAnalyticsConfiguration" : {
          "customerId" : azurerm_log_analytics_workspace.log.workspace_id
          "sharedKey" : azurerm_log_analytics_workspace.log.primary_shared_key
        }
      }
    }
  })
}

resource "azapi_update_resource" "aca_env" {
  type      = "Microsoft.App/managedEnvironments@2022-06-01-preview"
  name      = azapi_resource.aca_env.name
  parent_id = azurerm_resource_group.rg.id

  body = jsonencode({
    identity = {
      "type" : "SystemAssigned"
    }
  })

  depends_on = [
    azapi_resource.aca_env
  ]
}

resource "azurerm_role_assignment" "aks_acr_assignment" {
  principal_id                     = jsondecode(azapi_update_resource.aca_env.output).identity[0].principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
  depends_on = [
    azapi_update_resource.aca_env
  ]
}
