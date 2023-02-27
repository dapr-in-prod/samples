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

variable "frontend_port" {
  type        = number
  default     = 8080
  description = "Front End port number"
}

variable "vnet_ingress_address_space" {
  type        = string
  default     = "10.254.0.0/16"
  description = "Virtual network address space for ingress"
}

variable "vnet_ingress_frontend_subnet" {
  type        = string
  default     = "10.254.0.0/24"
  description = "Subnet address space for ingress frontend (AppGw)"
}

variable "vnet_ingress_backend_subnet" {
  type        = string
  default     = "10.254.2.0/24"
  description = "Subnet address space for ingress backend (AKS nodepool)"
}
