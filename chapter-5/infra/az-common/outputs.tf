output "sb_connection" {
  value = azurerm_servicebus_topic_authorization_rule.sb_load.primary_connection_string
}

output "eh_connection" {
  value = azurerm_eventhub_authorization_rule.eh_load.primary_connection_string
}
