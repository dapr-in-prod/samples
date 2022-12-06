resource "kubernetes_namespace" "dapr" {
  count = var.dapr_deploy ? 1 : 0
  metadata {
    name = var.dapr_namespace
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "helm_release" "dapr" {
  count = var.dapr_deploy ? 1 : 0
  name = "dapr"
  # determine chart url from https://github.com/dapr/helm-charts
  chart     = "https://github.com/dapr/helm-charts/raw/master/dapr-${var.dapr_version}.tgz"
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
