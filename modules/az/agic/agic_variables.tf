variable "location" {
  description = "The supported Azure location where the resource deployed"
  type        = string
}

variable "resource_group_id" {
  description = "Resource Id of the resource group to deploy resources into"
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

variable "app_namespace" {
  type        = string
  default     = "dip"
  description = "Kubernetes namespace to install sample application in"
}

variable "gateway_id" {
  description = "Resource Id of Application Gateway to link AGIC to"
  type        = string
}

variable "gateway_name" {
  description = "The name Application Gateway to link AGIC to"
  type        = string
}