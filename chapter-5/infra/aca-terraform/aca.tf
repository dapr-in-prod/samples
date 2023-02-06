# https://learn.microsoft.com/en-us/samples/azure-samples/container-apps-azapi-terraform/container-apps-azapi-terraform/

resource "azapi_resource" "aca_env" {
  name      = var.resource_prefix
  parent_id = azurerm_resource_group.rg.id
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  location  = azurerm_resource_group.rg.location
  
  tags      = local.tags

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = module.common.la_workspace_id
          sharedKey  = module.common.la_shared_key
        }
      }
      daprAIConnectionString   = module.common.ai_connection_string
      daprAIInstrumentationKey = module.common.ai_instrumentation_key
    }
  })
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

resource "azapi_resource" "dapr_component_pubsub" {
  name      = "pubsub-loadtest"
  parent_id = azapi_resource.aca_env.id
  type      = "Microsoft.App/managedEnvironments/daprComponents@2022-03-01"

  body = jsonencode({
    properties = {
      componentType = "pubsub.azure.servicebus"
      version       = "v1"
      secrets: [
        {
          name: "sb-connectionstring"
          value: module.azcommon.sb_connection
        }
      ]      
      metadata = [
        {
          name: "connectionString"
          secretRef: "sb-connectionstring"
        }
      ]
      scopes: [
        "sender",
        "receiver"
      ]      
    }
  })
}

