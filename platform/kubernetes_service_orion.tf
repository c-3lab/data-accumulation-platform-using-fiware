resource "kubernetes_secret" "fiware-orion-credentials" {
  metadata {
    name = "fiware-orion-credentials"
  }

  data = {
    mongodb_username = var.mongodb_username
    mongodb_password = var.mongodb_password
  }

  type = "Opaque"
}

resource "kubernetes_service" "orion" {
  metadata {
    name = "orion"
  }
  spec {
    selector = {
      name = kubernetes_deployment.orion.spec[0].template[0].spec[0].container.0.name
    }
    port {
      name = "orion"
      port = 1026
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "orion" {
  metadata {
    name = "orion"
    labels = {
      name = "orion"
    }
  }
  spec {
    replicas = var.orion_replicas

    selector {
      match_labels = {
        name = "orion"
      }
    }

    template {
      metadata {
        labels = {
          name = "orion"
        }
      }

      spec {
        container {
          image = var.orion_image_name
          name  = "orion"

          resources {
            requests {
              cpu    = "250m"
              memory = "128Mi"
            }
          }

          port {
            name           = "orion"
            container_port = 1026
          }

          env {
            name = "ORION_MONGO_USER"
            value_from {
              secret_key_ref {
                name = "fiware-orion-credentials"
                key  = "mongodb_username"
              }
            }
          }

          env {
            name = "ORION_MONGO_PASSWORD"
            value_from {
              secret_key_ref {
                name = "fiware-orion-credentials"
                key  = "mongodb_password"
              }
            }
          }

          args = ["-logLevel", var.orion_loglevel, "-dbSSL", "-dbhost", var.mongodb_host_port, "-rplSet", var.mongodb_rsname, "-dbTimeout", var.mongodb_timeout, "-db", "orion", "-dbAuthDb", var.mongodb_authdb, "-dbuser", "$(ORION_MONGO_USER)", "-dbpwd", "$(ORION_MONGO_PASSWORD)"]

          liveness_probe {
            tcp_socket {
              port = 1026
            }
            failure_threshold     = 12
            period_seconds        = 10
            initial_delay_seconds = 5
          }

          readiness_probe {
            tcp_socket {
              port = 1026
            }
            failure_threshold     = 12
            period_seconds        = 10
            initial_delay_seconds = 5
          }
        }
      }
    }
  }
}