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

# resource "azapi_resource" "container_app" {
#   type                      = "Microsoft.App/containerApps@2022-03-01"
#   name                      = "simple-js"
#   parent_id                 = azurerm_resource_group.rg.id
#   location                  = azurerm_resource_group.rg.location
#   response_export_values    = ["*"]
#   schema_validation_enabled = false

#   identity {
#     type         = "UserAssigned"
#     identity_ids = [module.common.acr_pull_id]
#   }

#   body = jsonencode({
#     properties = {
#       managedEnvironmentId = azapi_resource.aca_env.id
#       configuration = {
#         activeRevisionsMode = "Single"
#         secrets             = []
#         ingress = {
#           external   = true
#           targetPort = 5001
#           transport  = "auto"
#         }
#         dapr = {
#           appId       = "simple-js"
#           appPort     = 5001
#           appProtocol = "http"
#           enabled     = true
#         }
#         registries = [{
#           server   = module.common.acr_login_server
#           identity = module.common.acr_pull_id
#         }]
#       }
#       template = {
#         containers = [
#           {
#             name  = "simple-js"
#             image = "${module.common.acr_login_server}/simple-js:latest"
#             env   = []
#             resources = {
#               cpu    = ".25"
#               memory = ".5Gi"
#             }
#             probes = [
#               {
#                 type = "Liveness"
#                 httpGet = {
#                   port = 5001
#                   path = "health"
#                 }
#               },
#               {
#                 type = "Readiness"
#                 httpGet = {
#                   port = 5001
#                   path = "health"
#                 }
#               }
#             ]
#           }
#         ]
#         scale = {
#           minReplicas = 1
#           maxReplicas = 1
#           rules       = []
#         }
#       }
#     }
#   })
# }
