output "sb_connection" {
  value = azurerm_servicebus_namespace_authorization_rule.sb_load.primary_connection_string
}
