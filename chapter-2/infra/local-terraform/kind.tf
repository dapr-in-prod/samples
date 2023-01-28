provider "kind" {
}

resource "kind_cluster" "my_cluster" {
  name            = "my-dapr-cluster"
  kubeconfig_path = pathexpand(var.kube_config)
  wait_for_ready  = true
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    containerd_config_patches = [
      <<-TOML
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
            endpoint = ["http://kind-registry:5000"]
      TOML
    ]

    node {
      role = "control-plane"

      kubeadm_config_patches = [
        <<-TOML
          kind: InitConfiguration
          nodeRegistration:
            kubeletExtraArgs:
              node-labels: "ingress-ready=true"
        TOML
      ]
      
      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
        listen_address = "127.0.0.1"
      }
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

  depends_on = [
    docker_container.kind-registry
  ]
}

provider "helm" {
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
  count      = var.dapr_deploy ? 1 : 0
  name       = "dapr"
  repository = "https://dapr.github.io/helm-charts/"
  chart      = "dapr"
  namespace  = var.dapr_namespace
  timeout    = 1200

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
