provider helm {
  kubernetes {
    config_path = pathexpand(var.kube_config)
  }
}

provider kubernetes {
  config_path = pathexpand(var.kube_config)
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
