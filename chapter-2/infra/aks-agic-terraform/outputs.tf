output "resource_group" {
  value = var.resource_group
}

output "resource_prefix" {
  value = var.resource_prefix
}

output "location" {
  value = var.location
}

output "cluster_name" {
  value = module.aks.CLUSTER_NAME
}

output "gateway_public_ip" {
  value = module.appgw.GATEWAY_PUBLIC_IP
}

output "gateway_frontend_port" {
  value = module.appgw.GATEWAY_FRONTEND_PORT
}

output "acr_name" {
  value = module.acr.CONTAINER_REGISTRY_NAME
}

output "acr_login_server" {
  value = module.acr.CONTAINER_REGISTRY_ENDPOINT
}

output "acr_pull_id" {
  value = module.acr.CONTAINER_REGISTRY_PULL_IDENTITY_ID
}

output "kv_name" {
  value = module.keyvault.KEYVAULT_NAME
}

output "kv_consumer_id" {
  value = module.keyvault.KEYVAULT_CONSUMER_ID
}

output "kv_consumer_name" {
  value = module.keyvault.KEYVAULT_CONSUMER_NAME
}

output "kv_consumer_client_id" {
  value = module.keyvault.KEYVAULT_CONSUMER_CLIENT_ID
}
