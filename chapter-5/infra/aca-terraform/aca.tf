resource "azurerm_container_app_environment" "aca_env" {
  name                = var.resource_prefix
  resource_group_name = var.resource_group
  location            = azurerm_resource_group.rg.location
  tags                = local.tags

  log_analytics_workspace_id = module.common.la_id
}

resource "azurerm_container_app_environment_dapr_component" "dapr_component_secretstore" {
  name                         = "secretstore"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  component_type               = "secretstores.azure.keyvault"
  version                      = "v1"
  metadata {
    name  = "vaultName"
    value = module.common.kv_name
  }
  metadata {
    name  = "spnClientId"
    value = module.common.kv_consumer_clientid
  }
}

resource "azurerm_container_app_environment_dapr_component" "dapr_component_pubsub_sb" {
  name      = "pubsub-loadtest-sb"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  component_type               = "pubsub.azure.servicebus"
  version                      = "v1"
  metadata {
    name  = "connectionString"
    value = module.azcommon.sb_connection
  }
  scopes = [
        "sender",
        "receiver"
  ]
}

resource "azurerm_container_app_environment_dapr_component" "dapr_component_pubsub_eh" {
  name      = "pubsub-loadtest-eh"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  component_type               = "pubsub.azure.servicebus"
  version                      = "v1"
  metadata {
    name  = "connectionString"
    value = module.azcommon.eh_connection
  }
  scopes = [
        "sender",
        "receiver"
  ]
}
