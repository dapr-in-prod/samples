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
