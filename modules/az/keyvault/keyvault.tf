data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                = "${var.resource_prefix}-kv"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  sku_name = "standard"

  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  enable_rbac_authorization  = true
}

resource "azurerm_role_assignment" "kv_admin_assignment" {
  for_each             = toset(var.secretstore_admins)
  principal_id         = each.value
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.kv.id
}

resource "azurerm_role_assignment" "kv_sp_admin_assignment" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Administrator"
  scope                = azurerm_key_vault.kv.id
}

resource "azurerm_user_assigned_identity" "kv_consumer_identity" {
  name                = "${var.resource_prefix}-kvconsumer"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_role_assignment" "kv_consumer_assignment" {
  principal_id         = azurerm_user_assigned_identity.kv_consumer_identity.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.kv.id
}
