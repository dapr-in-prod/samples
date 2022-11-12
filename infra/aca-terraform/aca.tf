resource "azapi_resource" "aca_env" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
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

resource "azapi_resource" "container_app" {
  type                      = "Microsoft.App/containerApps@2022-03-01"
  name                      = "simple-js"
  parent_id                 = azurerm_resource_group.rg.id
  location                  = azurerm_resource_group.rg.location
  response_export_values    = ["*"]
  schema_validation_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr_pull_identity.id]
  }

  body = jsonencode({
    properties = {
      managedEnvironmentId = azapi_resource.aca_env.id
      configuration = {
        activeRevisionsMode = "Single"
        secrets             = []
        ingress = {
          external   = true
          targetPort = 5001
          transport  = "auto"
        }
        dapr = {
          appId       = "simple-js"
          appPort     = 5001
          appProtocol = "http"
          enabled     = true
        }
        registries = [{
          server   = azurerm_container_registry.acr.login_server
          identity = azurerm_user_assigned_identity.acr_pull_identity.id
        }]
      }
      template = {
        containers = [
          {
            name  = "simple-js"
            image = "${azurerm_container_registry.acr.login_server}/simple-js:latest"
            env = [
            ]
            resources = {
              cpu    = ".25"
              memory = ".5Gi"
            }
          }
        ]
        scale = {
          minReplicas = 1
          maxReplicas = 1
          rules       = []
        }
      }
    }
  })
}
