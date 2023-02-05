resource "docker_container" "redis" {
  name    = "redis"
  image   = "redis:6"
  restart = "always"
  ports {
    internal = var.redis_port
    external = var.redis_port
    ip       = "127.0.0.1"
  }
  networks_advanced {
    name = docker_network.kind.name
  }

  depends_on = [
    docker_network.kind
  ]
}
