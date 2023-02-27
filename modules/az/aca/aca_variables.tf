variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "resource_prefix" {
  description = "A suffix string to centrally mitigate resource name collisions."
  type        = string
}

variable "tags" {
  description = "A list of tags used for deployed services."
  type        = map(string)
}

variable "loganalytics_id" {
  description = "Resource Id of Log Analytics."
  type        = string
}

variable "keyvault_name" {
  description = "Key Vault name to be used in secretstores.azure.keyvault."
  type        = string
}

variable "kv_consumer_client_id" {
  description = "Key Vault consuming user identity's client id to be used in secretstores.azure.keyvault."
  type        = string
}
