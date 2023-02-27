variable "cluster_name" {
  description = "AKS cluster name."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to deploy resources into"
  type        = string
}

variable "dapr_version" {
  type        = string
  default     = "1.9.5"
  description = "Dapr version to install with Helm charts"
}

variable "dapr_namespace" {
  type        = string
  default     = "dapr-system"
  description = "Kubernetes namespace to install Dapr in"
}
