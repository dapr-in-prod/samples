data "azurerm_resource_group" "node_rg" {
  name = var.node_resource_group
}

data "azurerm_user_assigned_identity" "agentpool" {
  name                = "${var.cluster_name}-agentpool"
  resource_group_name = data.azurerm_resource_group.node_rg.name
}

resource "azurerm_role_assignment" "agentpool_mio_node_rg" {
  scope                            = data.azurerm_resource_group.node_rg.id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = data.azurerm_user_assigned_identity.agentpool.principal_id
  skip_service_principal_aad_check = true

}

resource "azurerm_role_assignment" "agentpool_vmc_node_rg" {
  scope                            = data.azurerm_resource_group.node_rg.id
  role_definition_name             = "Virtual Machine Contributor"
  principal_id                     = data.azurerm_user_assigned_identity.agentpool.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "agentpool_mio_rg" {
  scope                            = var.resource_group_id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = data.azurerm_user_assigned_identity.agentpool.principal_id
  skip_service_principal_aad_check = true
}

# determine chart url from https://github.com/Azure/aad-pod-identity/tree/master/charts
# as AAD Pod Identity is deprecated, there should be no more substantial updates
# it will be replaced by https://azure.github.io/azure-workload-identity/docs/ which is not yet support by Go SDKs and thus Dapr

resource "helm_release" "aad-pod-identity" {
  name      = "mic-aad-pod-identity"
  chart     = "https://github.com/Azure/aad-pod-identity/raw/master/charts/aad-pod-identity-4.1.15.tgz"
  namespace = "kube-system"
  timeout   = 1200

  depends_on = [
    azurerm_role_assignment.agentpool_mio_node_rg,
    azurerm_role_assignment.agentpool_vmc_node_rg,
    azurerm_role_assignment.agentpool_mio_rg
  ]
}
