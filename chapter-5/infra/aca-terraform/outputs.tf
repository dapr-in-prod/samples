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
  value = module.common.acr_name
}

output "acr_login_server" {
  value = module.common.acr_login_server
}

output "acr_pull_id" {
  value = module.common.acr_pull_id
}

output "aca_name" {
  value = azurerm_container_app_environment.aca_env.name
}

output "kv_consumer_id" {
  value = module.common.kv_consumer_id
}
