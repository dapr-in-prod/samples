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
  value = azurerm_log_analytics_workspace.log.primary_shared_key
  sensitive = true
}
