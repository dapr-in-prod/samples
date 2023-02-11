resource "random_string" "simple-js-secret" {
  length = 20
}

resource "azurerm_key_vault_secret" "simple_secret" {
  name         = "simple-js-secret"
  value        = random_string.simple-js-secret.result
  key_vault_id = module.common.kv_id

  # creation or deletion requires Service Principal administration assignment
  depends_on = [
    module.common.kv_sp_admin_assignment
  ]
}

resource "azurerm_key_vault_secret" "sb_connectionstring" {
  name         = "sb-connectionstring"
  value        = module.azcommon.sb_connection
  key_vault_id = module.common.kv_id

  # creation or deletion requires Service Principal administration assignment
  depends_on = [
    module.common.kv_sp_admin_assignment
  ]
}

resource "azurerm_key_vault_secret" "eh_connectionstring" {
  name         = "eh-connectionstring"
  value        = module.azcommon.eh_connection
  key_vault_id = module.common.kv_id

  # creation or deletion requires Service Principal administration assignment
  depends_on = [
    module.common.kv_sp_admin_assignment
  ]
}
