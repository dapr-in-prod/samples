data "azurerm_client_config" "current" {}

# https://learn.microsoft.com/en-us/samples/azure-samples/private-aks-cluster-terraform-devops/private-aks-cluster-terraform-devops/

resource "random_pet" "akssuffix" {}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.resource_prefix
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "${var.resource_prefix}-${random_pet.akssuffix.id}"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name            = "default"
    node_count      = 3
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30
    vnet_subnet_id  = azurerm_subnet.backend.id
  }

  network_profile {
      network_plugin = "azure"
      service_cidr   = "10.2.0.0/24"
      dns_service_ip = "10.2.0.10"
      docker_bridge_cidr = "172.17.0.1/16"
      network_policy = "calico"
      load_balancer_sku = "standard"
  }

  role_based_access_control_enabled = true
  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.cluster_admins
  }

  oms_agent {
    log_analytics_workspace_id = module.common.la_id
  }

  tags = local.tags
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

# assign roles required for Container Registry pull

resource "azurerm_role_assignment" "acr_role_assignment" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope                = module.common.acr_id
  role_definition_name = "AcrPull"
}
