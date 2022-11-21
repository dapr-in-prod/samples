# https://learn.microsoft.com/en-us/samples/azure-samples/private-aks-cluster-terraform-devops/private-aks-cluster-terraform-devops/

resource "random_pet" "akssuffix" {}

resource "null_resource" "enable_oidci_issuer" {
  provisioner "local-exec" {
    command = <<-EOT
      az feature register --name EnableOIDCIssuerPreview --namespace Microsoft.ContainerService
    EOT
  }
}

resource "null_resource" "enable_workload_identity" {
  provisioner "local-exec" {
    command = <<-EOT
      az feature register --name EnableWorkloadIdentityPreview --namespace Microsoft.ContainerService
    EOT
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.resource_prefix
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "${var.resource_prefix}-${random_pet.akssuffix.id}"

  depends_on = [
    null_resource.enable_oidci_issuer,
    null_resource.enable_workload_identity
  ]

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  oms_agent {
    log_analytics_workspace_id = module.common.la_id
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "acr_role_assignment" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope                = module.common.acr_id
  role_definition_name = "AcrPull"
}

resource "azurerm_log_analytics_solution" "aks_insights" {
  solution_name         = "ContainerInsights"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  workspace_resource_id = module.common.la_id
  workspace_name        = module.common.la_name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
