terraform {
  required_providers {
    kind = {
      source  = "kyma-incubator/kind"
      version = "0.0.11"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.3.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }
  }
}

