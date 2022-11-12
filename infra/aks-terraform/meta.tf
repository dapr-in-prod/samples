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
  }
}
