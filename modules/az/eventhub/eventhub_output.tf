output "LOAD_CONNECTION_STRING" {
  value = azurerm_eventhub_authorization_rule.eh_load.primary_connection_string
}
