variable "dapr_deploy" {
  type = bool
  default = true
  description = "Indicate whether to deploy Dapr directly with cluster"
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

variable "kube_config" {
  type    = string
  default = "~/.kube/config"
}