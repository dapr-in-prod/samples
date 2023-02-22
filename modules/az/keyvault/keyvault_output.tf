output "KEYVAULT_ID" {
  value = azurerm_key_vault.kv.id
}

output "KEYVAULT_NAME" {
  value = azurerm_key_vault.kv.name
}

output "KEYVAULT_CONSUMER_ID" {
  value = azurerm_user_assigned_identity.kv_consumer_identity.id
}

output "KEYVAULT_CONSUMER_CLIENT_ID" {
  value = azurerm_user_assigned_identity.kv_consumer_identity.client_id
}
