resource "kubernetes_secret" "fiware-cygnus-credentials" {
  metadata {
    name = "fiware-cygnus-credentials"
  }

  data = {
    postgresql_user     = "${var.psql_admin_user}@${azurerm_postgresql_server.psql.name}"
    postgresql_password = var.psql_admin_password
  }

  type = "Opaque"
}

resource "kubernetes_service" "cygnus" {
  metadata {
    name = "cygnus"
  }

  spec {
    selector = {
      name = kubernetes_deployment.cygnus.spec[0].template[0].spec[0].container.0.name
    }

    port {
      name = "service-port"
      port = 5055
    }

    port {
      name = "api-port"
      port = 5080
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "cygnus" {
  metadata {
    name = "cygnus"
    labels = {
      name = "cygnus"
    }
  }

  spec {
    replicas = var.cygnus_replicas

    selector {
      match_labels = {
        name = "cygnus"
      }
    }

    template {
      metadata {
        labels = {
          name = "cygnus"
        }
      }

      spec {
        container {
          image = var.cygnus_image_name
          name  = "cygnus"

          resources {
            requests {
              cpu    = "250m"
              memory = "128Mi"
            }
          }

          port {
            name           = "service-port"
            container_port = 5055
          }

          port {
            name           = "api-port"
            container_port = 5080
          }

          env {
            name  = "CYGNUS_POSTGRESQL_HOST"
            value = azurerm_postgresql_server.psql.fqdn
          }

          env {
            name  = "CYGNUS_POSTGRESQL_PORT"
            value = "5432"
          }

          env {
            name  = "CYGNUS_POSTGRESQL_DATABASE"
            value = "cygnusdb"
          }

          env {
            name = "CYGNUS_POSTGRESQL_USER"
            value_from {
              secret_key_ref {
                name = "fiware-cygnus-credentials"
                key  = "postgresql_user"
              }
            }
          }

          env {
            name = "CYGNUS_POSTGRESQL_PASS"
            value_from {
              secret_key_ref {
                name = "fiware-cygnus-credentials"
                key  = "postgresql_password"
              }
            }
          }

          env {
            name  = "CYGNUS_POSTGRESQL_OPTIONS"
            value = "sslmode=require"
          }

          env {
            name  = "CYGNUS_LOG_LEVEL"
            value = var.cygnus_loglevel
          }

          env {
            name  = "CYGNUS_SERVICE_PORT"
            value = 5055
          }

          env {
            name  = "CYGNUS_API_PORT"
            value = 5080
          }

          env {
            name  = "CYGNUS_POSTGRESQL_DATA_MODEL"
            value = "dm-by-entity-type"
          }

          //env {
          //  name  = "CYGNUS_POSTGRESQL_ATTR_PERSISTENCE"
          //  value = "column"
          //}

          env {
            name  = "CYGNUS_POSTGRESQL_ATTR_NATIVE_TYPES"
            value = true
          }

          env {
            name  = "CYGNUS_POSTGRESQL_ENABLE_ENCODING"
            value = false
          }

          liveness_probe {
            tcp_socket {
              port = 5080
            }
            failure_threshold     = 12
            period_seconds        = 10
            initial_delay_seconds = 5
          }

          readiness_probe {
            tcp_socket {
              port = 5080
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

