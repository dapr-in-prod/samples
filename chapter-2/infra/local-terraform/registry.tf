provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_container" "kind-registry" {
  name    = "kind-registry"
  image   = "registry:2"
  restart = "always"
  ports {
    internal = 5000
    external = 5000
    ip       = "127.0.0.1"
  }
  networks_advanced {
    name = "kind"
  }
}
