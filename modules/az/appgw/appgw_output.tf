output "GATEWAY_ID" {
  value = azurerm_application_gateway.gw.id
}

output "GATEWAY_NAME" {
  value = azurerm_application_gateway.gw.name
}

output "BACKEND_SUBNET_ID" {
  value = azurerm_subnet.backend.id
}

output "GATEWAY_PUBLIC_IP" {
  value = azurerm_public_ip.ingress.ip_address
}

output "GATEWAY_FRONTEND_PORT" {
  value = "${one([for fep in azurerm_application_gateway.gw.frontend_port : fep.port if fep.name == "${local.frontend_port_name}"])}"
}