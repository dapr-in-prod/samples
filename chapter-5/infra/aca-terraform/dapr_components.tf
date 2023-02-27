resource "azurerm_container_app_environment_dapr_component" "dapr_component_secretstore" {
  name                         = "secretstore"
  container_app_environment_id = module.aca.CONTAINER_APP_ENV_ID
  component_type               = "secretstores.azure.keyvault"
  version                      = "v1"
  metadata {
    name  = "vaultName"
    value = module.keyvault.KEYVAULT_NAME
  }
  metadata {
    name  = "spnClientId"
    value = module.keyvault.KEYVAULT_CONSUMER_CLIENT_ID
  }
}

resource "azurerm_container_app_environment_dapr_component" "dapr_component_pubsub_sb" {
  name                         = "pubsub-loadtest-sb"
  container_app_environment_id = module.aca.CONTAINER_APP_ENV_ID
  component_type               = "pubsub.azure.servicebus"
  version                      = "v1"
  metadata {
    name  = "connectionString"
    value = module.servicebus.LOAD_CONNECTION_STRING
  }
  scopes = [
    "sender",
    "receiver"
  ]
}

resource "azurerm_container_app_environment_dapr_component" "dapr_component_pubsub_eh" {
  name                         = "pubsub-loadtest-eh"
  container_app_environment_id = module.aca.CONTAINER_APP_ENV_ID
  component_type               = "pubsub.azure.servicebus"
  version                      = "v1"
  metadata {
    name  = "connectionString"
    value = module.eventhub.LOAD_CONNECTION_STRING
  }
  scopes = [
    "sender",
    "receiver"
  ]
}
