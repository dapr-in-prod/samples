variable "location" {
  type        = string
  default     = "eastus"
  description = "Desired Azure Region"
}

variable "resourceGroup" {
  type        = string
  default     = "rg-dip-aks"
  description = "Desired Resource Group Name"
}