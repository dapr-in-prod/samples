provider "helm" {
  kubernetes {
    config_path = kind_cluster.my_cluster.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = kind_cluster.my_cluster.kubeconfig_path
}


resource "helm_release" "ingress_nginx" {
  count = var.ingress_nginx_deploy ? 1 : 0

  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = var.ingress_nginx_helm_version

  namespace        = var.ingress_nginx_namespace
  create_namespace = true

  values = [file("nginx-ingress-values.yaml")]

  depends_on = [kind_cluster.my_cluster]
}

resource "null_resource" "wait_for_ingress_nginx" {
  triggers = {
    key = uuid()
  }

  provisioner "local-exec" {
    command = <<EOF
      printf "\nWaiting for the nginx ingress controller...\n"
      kubectl wait --namespace ${helm_release.ingress_nginx.namespace} \
        --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
        --timeout=90s
    EOF
  }

  depends_on = [helm_release.ingress_nginx]
}

resource "helm_release" "dapr" {
  count      = var.dapr_deploy ? 1 : 0
  name       = "dapr"
  repository = "https://dapr.github.io/helm-charts/"
  chart      = "dapr"

  namespace        = var.dapr_namespace
  create_namespace = true

  timeout = 1200

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
