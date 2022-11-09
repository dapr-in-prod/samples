resource "random_pet" "prefix" {}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "dip-aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  dns_prefix          = "dip-aks-${random_pet.prefix.id}"

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

  tags = local.tags
}
