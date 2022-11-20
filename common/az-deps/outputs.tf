output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_identity" {
  value = azurerm_user_assigned_identity.acr_pull_identity.id
}

output "la_workspace_id" {
  value = azurerm_log_analytics_workspace.log.workspace_id
}

output "la_shared_key" {
  value     = azurerm_log_analytics_workspace.log.primary_shared_key
  sensitive = true
}

output "kv_name" {
  value = azurerm_key_vault.kv.name
}

output "kv_id" {
  value = azurerm_key_vault.kv.id
}

output "kv_consumer_clientid" {
  value = azurerm_user_assigned_identity.kv_consumer_identity.client_id
}

output "kv_sp_admin_assignment" {
  value = azurerm_role_assignment.kv_sp_admin_assignment.id
}
