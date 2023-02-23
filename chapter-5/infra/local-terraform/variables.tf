variable "cluster_name" {
  type        = string
  default     = "my-dapr-cluster"
  description = "Name of KinD cluster to deploy"
}

variable "dapr_deploy" {
  type        = bool
  default     = true
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

variable "kube_config_path" {
  type        = string
  default     = "~/.kube/config"
  description = "Path to kubectl configuration"
}

variable "ingress_nginx_deploy" {
  type        = bool
  default     = true
  description = "Indicate whether to deploy NGINX ingress controller directly with cluster"
}

variable "ingress_nginx_helm_version" {
  type        = string
  description = "The Helm version for the nginx ingress controller."
  default     = "4.0.6"
}

variable "ingress_nginx_namespace" {
  type        = string
  description = "The nginx ingress namespace (it will be created if needed)."
  default     = "ingress-nginx"
}

variable "registry_port" {
  type = number
  description = "Port which local registry uses to listen on."
  default = 5000
}

variable "redis_port" {
  type = number
  description = "Port which Redis uses to listen on."
  default = 6379
}
