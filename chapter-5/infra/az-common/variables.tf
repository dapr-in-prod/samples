variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure Region"
}

variable "resource_group" {
  type        = string
  default     = "rg-dip-aks"
  description = "Resource Group Name"
}

variable "resource_prefix" {
  type        = string
  default     = "dipaks"
  description = "Resource Prefix to be used for all resources"
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}
