terraform {
  backend "azurerm" {}
  required_version = "~>1.3.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.30.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~>1.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      # only keep this setting while evaluating - remove for production
      prevent_deletion_if_contains_resources = false
    }
    application_insights {
      disable_generated_rule = true
    }
    key_vault {
      # only keep this setting while evaluating - remove for production
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "helm" {
  debug = false

  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate)
  }
}

provider "kubernetes" {
  host                   = "${azurerm_kubernetes_cluster.aks.kube_admin_config.0.host}"
  username               = "${azurerm_kubernetes_cluster.aks.kube_admin_config.0.username}"
  password               = "${azurerm_kubernetes_cluster.aks.kube_admin_config.0.password}"
  client_certificate     = base64decode("${azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate}")
  client_key             = base64decode("${azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key}")
  cluster_ca_certificate = base64decode("${azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate}")
}
