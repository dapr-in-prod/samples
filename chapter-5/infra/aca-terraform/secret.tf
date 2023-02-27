resource "random_string" "simple-js-secret" {
  length = 20
}

resource "azurerm_key_vault_secret" "simple_secret" {
  name         = "simple-js-secret"
  value        = random_string.simple-js-secret.result
  key_vault_id = module.keyvault.KEYVAULT_ID

  depends_on = [
    module.keyvault
  ]
}
