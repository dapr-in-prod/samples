provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_container" "kind_registry" {
  name    = "kind-registry"
  image   = "registry:2"
  restart = "always"
  ports {
    internal = var.registry_port
    external = var.registry_port
    ip       = "127.0.0.1"
  }
  networks_advanced {
    name = docker_network.kind.name
  }

  depends_on = [
    docker_network.kind
  ]
}
