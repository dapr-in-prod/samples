data "azurerm_client_config" "current" {}

# https://learn.microsoft.com/en-us/samples/azure-samples/private-aks-cluster-terraform-devops/private-aks-cluster-terraform-devops/

resource "random_pet" "akssuffix" {}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.resource_prefix}-aks"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  dns_prefix          = "${var.resource_prefix}-${random_pet.akssuffix.id}"

  default_node_pool {
    name            = "default"
    node_count      = 3
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true
  azure_active_directory_role_based_access_control {
    managed            = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled = true
  }

  oms_agent {
    log_analytics_workspace_id = var.loganalytics_id
  }
}

resource "azurerm_log_analytics_solution" "aks_insights" {
  solution_name         = "ContainerInsights"
  resource_group_name   = var.resource_group_name
  location              = var.location
  workspace_resource_id = var.loganalytics_id
  workspace_name        = var.loganalytics_name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# assign role for AKS cluster admins

resource "azurerm_role_assignment" "aks_admin_role_assignment" {
  for_each             = toset(var.cluster_admins)
  principal_id         = each.value
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
}

# assign role required for Container Registry pull

resource "azurerm_role_assignment" "acr_role_assignment" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  scope                = var.acr_id
  role_definition_name = "AcrPull"
}
