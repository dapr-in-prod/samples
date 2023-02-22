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
