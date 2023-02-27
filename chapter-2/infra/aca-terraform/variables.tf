variable "location" {
  type        = string
  default     = "eastus"
  description = "Desired Azure Region"
}

variable "resource_group" {
  type        = string
  default     = "rg-dip-aca"
  description = "Desired Resource Group Name"
}

variable "resource_prefix" {
  type        = string
  default     = "dipaca"
  description = "Desired Resource Prefix to be used for all resources"
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    project = "dapr-in-prod"
  }
}

variable "soft_delete_retention_days" {
  type        = number
  default     = 7
  description = "Number of days deleted Azure Key Vault resources are retained."
}

variable "purge_protection_enabled" {
  type        = bool
  default     = true
  description = "Enables purge protection on Azure Key Vault"
}

variable "secretstore_admins" {
  type        = list(string)
  default     = []
  description = "List of Key Vault administrator object / principal Ids"
}
