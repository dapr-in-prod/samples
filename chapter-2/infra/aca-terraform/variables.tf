variable "location" {
  type        = string
  default     = "eastus"
  description = "Desired Azure Region"
}

variable "resourceGroup" {
  type        = string
  default     = "rg-dip-aca"
  description = "Desired Resource Group Name"
}

variable "resourcePrefix" {
  type        = string
  default     = "dipaca"
  description = "Desired Resource Prefix to be used for all resources"
}