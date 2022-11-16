resource "random_string" "acrsuffix" {
  length = 10
  special = false
  upper = false
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.resourcePrefix}${random_string.acrsuffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_user_assigned_identity" "acr_pull_identity" {
  name                = "${var.resourcePrefix}-aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "aks_acr_assignment" {
  principal_id                     = azurerm_user_assigned_identity.acr_pull_identity.principal_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
