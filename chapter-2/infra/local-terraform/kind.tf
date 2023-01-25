terraform {
  required_providers {
    kind = {
      source = "kyma-incubator/kind"
      version = "0.0.11"
    }
  }
}

provider "kind" {
}

resource "kind_cluster" "my_cluster" {
  name = "my-dapr-cluster"
  kubeconfig_path = pathexpand(var.kube_config)
  wait_for_ready = true
  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }
  }
}

provider helm {
  kubernetes {
    config_path = kind_cluster.my_cluster.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = kind_cluster.my_cluster.kubeconfig_path
}

resource "kubernetes_namespace" "dapr" {
  count = var.dapr_deploy ? 1 : 0
  metadata {
    name = var.dapr_namespace
  }

  depends_on = [
    kind_cluster.my_cluster
  ]
}

resource "helm_release" "dapr" {
  count = var.dapr_deploy ? 1 : 0
  name = "dapr"
  repository = "https://dapr.github.io/helm-charts/"
  chart     = "dapr"
  namespace = var.dapr_namespace
  timeout   = 1200

  set {
    name  = "global.ha.enabled"
    value = "true"
  }

  set {
    name  = "global.tag"
    value = "${var.dapr_version}-mariner"
  }

  depends_on = [
    kubernetes_namespace.dapr
  ]
}
