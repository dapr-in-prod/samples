resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_prefix}-net"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = [var.vnet_ingress_address_space]

  tags = local.tags
}

resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vnet_ingress_frontend_subnet]
}

resource "azurerm_subnet" "backend" {
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.vnet_ingress_backend_subnet]
}

resource "azurerm_public_ip" "ingress" {
  name                = "${var.resource_prefix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  allocation_method   = "Static"
}

locals {
  backend_address_pool_name      = "beap"
  frontend_port_name             = "feport"
  frontend_ip_configuration_name = "feip"
  http_setting_name              = "be-htst"
  listener_name                  = "httplstn"
  request_routing_rule_name      = "rqrt"
  redirect_configuration_name    = "rdrcfg"
}

resource "azurerm_application_gateway" "gw" {
  name                = "${var.resource_prefix}-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "gw-ip-config"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ingress.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    port                  = 80
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    backend_address_pool_name  = local.backend_address_pool_name
    http_listener_name         = local.listener_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  tags = local.tags
}
