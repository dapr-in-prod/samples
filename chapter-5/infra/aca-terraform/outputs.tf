output "resource_group" {
  value = var.resource_group
}

output "resource_prefix" {
  value = var.resource_prefix
}

output "location" {
  value = var.location
}

output "acr_name" {
  value = module.acr.CONTAINER_REGISTRY_NAME
}

output "acr_login_server" {
  value = module.acr.CONTAINER_REGISTRY_ENDPOINT
}

output "acr_pull_id" {
  value = module.acr.CONTAINER_REGISTRY_PULL_IDENTITY_ID
}

output "aca_name" {
  value = module.aca.CONTAINER_APP_ENV_NAME
}

output "kv_consumer_id" {
  value = module.keyvault.KEYVAULT_CONSUMER_ID
}
