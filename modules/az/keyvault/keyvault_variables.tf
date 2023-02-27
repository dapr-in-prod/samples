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

variable "soft_delete_retention_days" {
  type        = number
  default     = 7
  description = "Number of days deleted Azure Key Vault resources are retained."
}

variable "purge_protection_enabled" {
  type        = bool
  default     = false
  description = "Enables purge protection on Azure Key Vault"
}

variable "secretstore_admins" {
  type        = list(string)
  default     = []
  description = "List of Key Vault administrator object / principal Ids"
}
