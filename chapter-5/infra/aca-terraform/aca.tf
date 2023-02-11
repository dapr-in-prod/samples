# https://learn.microsoft.com/en-us/samples/azure-samples/container-apps-azapi-terraform/container-apps-azapi-terraform/

resource "azapi_resource" "aca_env" {
  name      = var.resource_prefix
  parent_id = azurerm_resource_group.rg.id
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  location  = azurerm_resource_group.rg.location

  tags = local.tags

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "azure-monitor"
      }
      daprAIConnectionString   = module.common.ai_connection_string
      daprAIInstrumentationKey = module.common.ai_instrumentation_key
    }
  })
}

resource "azurerm_monitor_diagnostic_setting" "aca_diag" {
  name                       = "${var.resource_prefix}-diag"
  target_resource_id         = azapi_resource.aca_env.id
  log_analytics_workspace_id = module.common.la_id

  log {
    category = "ContainerAppConsoleLogs"
    retention_policy {
      enabled = true
      days    = 2
    }
  }

  log {
    category = "ContainerAppSystemLogs"
    retention_policy {
      enabled = true
      days    = 2
    }
  }

  metric {
    category = "AllMetrics"
    retention_policy {
      enabled = true
      days    = 10
    }
  }
}

resource "azapi_resource" "dapr_component_secretstore" {
  name      = "secretstore"
  parent_id = azapi_resource.aca_env.id
  type      = "Microsoft.App/managedEnvironments/daprComponents@2022-03-01"

  body = jsonencode({
    properties = {
      componentType = "secretstores.azure.keyvault"
      version       = "v1"
      metadata = [
        {
          name  = "vaultName"
          value = module.common.kv_name
        },
        {
          name  = "spnClientId"
          value = module.common.kv_consumer_clientid
        }
      ]
    }
  })
}

resource "azapi_resource" "dapr_component_pubsub_sb" {
  name      = "pubsub-loadtest-sb"
  parent_id = azapi_resource.aca_env.id
  type      = "Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview"

  body = jsonencode({
    properties = {
      componentType = "pubsub.azure.servicebus"
      version       = "v1"
      metadata = [
        {
          name : "connectionString"
          secretRef : azurerm_key_vault_secret.sb_connectionstring.name
        }
      ]
      scopes : [
        "sender",
        "receiver"
      ]
      secretStoreComponent : azapi_resource.dapr_component_secretstore.name
    }
  })
}

resource "azapi_resource" "dapr_component_pubsub_eh" {
  name      = "pubsub-loadtest-eh"
  parent_id = azapi_resource.aca_env.id
  type      = "Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview"

  body = jsonencode({
    properties = {
      componentType = "pubsub.azure.eventhubs"
      version       = "v1"
      metadata = [
        {
          name : "connectionString"
          secretRef : azurerm_key_vault_secret.eh_connectionstring.name
        }
      ]
      scopes : [
        "sender",
        "receiver"
      ]
      secretStoreComponent : azapi_resource.dapr_component_secretstore.name
    }
  })
}

