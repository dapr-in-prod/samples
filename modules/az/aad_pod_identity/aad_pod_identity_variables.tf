variable "resource_group_id" {
  description = "Resource Id of the resource group to deploy resources into"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "cluster_id" {
  description = "AKS cluster id."
  type        = string
}

variable "cluster_name" {
  description = "AKS cluster name."
  type        = string
}

variable "node_resource_group" {
  description = "AKS node resource group."
  type        = string
}
