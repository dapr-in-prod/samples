resource "random_pet" "akssuffix" {}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.resourcePrefix
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "${var.resourcePrefix}-${random_pet.akssuffix.id}"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.acr_pull_identity.id]
  }

  role_based_access_control_enabled = true

  tags = local.tags
}
