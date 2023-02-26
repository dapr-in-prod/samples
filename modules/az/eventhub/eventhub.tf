resource "azurerm_eventhub_namespace" "eh" {
  name                = "${var.resource_prefix}eh"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku      = "Standard"
  capacity = 1
}

resource "azurerm_eventhub" "load" {
  name                = "load"
  namespace_name      = azurerm_eventhub_namespace.eh.name
  resource_group_name = var.resource_group_name

  partition_count   = 2
  message_retention = 1
}

resource "azurerm_eventhub_authorization_rule" "eh_load" {
  name                = "send_listen"
  namespace_name      = azurerm_eventhub_namespace.eh.name
  eventhub_name       = azurerm_eventhub.load.name
  resource_group_name = var.resource_group_name
  listen              = true
  send                = true
  manage              = true
}
