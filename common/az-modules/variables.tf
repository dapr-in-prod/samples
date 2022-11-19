variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure Region"
}

variable "resourceGroup" {
  type        = string
  default     = "rg-dip-aks"
  description = "Resource Group Name"
}

variable "resourcePrefix" {
  type        = string
  default     = "dipaks"
  description = "Resource Prefix to be used for all resources"
}

variable "tags" {
  type        = map(string)
  description = "Tags to set for all resources"
  default     = {}
}
