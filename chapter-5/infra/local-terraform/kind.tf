provider "kind" {
}

resource "docker_network" "kind" {
  name   = "kind"
  driver = "bridge"
}

resource "kind_cluster" "my_cluster" {
  name            = var.cluster_name
  kubeconfig_path = pathexpand(var.kube_config_path)
  wait_for_ready  = true
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    containerd_config_patches = [
      <<-TOML
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:5000"]
            endpoint = ["http://${docker_container.kind_registry.hostname}:${var.registry_port}"]
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
    docker_container.kind_registry
  ]
}
