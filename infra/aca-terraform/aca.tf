resource "azapi_resource" "aca_env" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  name      = var.resourcePrefix
  tags      = local.tags
  # identity {
  #   type = "UserAssigned"
  #   identity_ids = [
  #     azurerm_user_assigned_identity.acr_pull_identity.id
  #   ]
  # }
  # schema_validation_enabled = false

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
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  name      = azapi_resource.aca_env.name
  parent_id = azurerm_resource_group.rg.id

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
    identity = {
      # "type" : "SystemAssigned"
      "type" : "UserAssigned"
      "userAssignedIdentities" : {
        "${azurerm_user_assigned_identity.acr_pull_identity.principal_id}" : {}
      }
    }
  })

  depends_on = [
    azapi_resource.aca_env
  ]
}
