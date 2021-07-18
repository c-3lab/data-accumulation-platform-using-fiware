resource "kubernetes_secret" "servicebus-credentials" {
  metadata {
    name = "servicebus-credentials"
  }

  data = {
    ruleName   = azurerm_servicebus_namespace_authorization_rule.amqp10-converter.name
    primaryKey = azurerm_servicebus_namespace_authorization_rule.amqp10-converter.primary_key
  }

  type = "Opaque"
}

resource "kubernetes_secret" "iot-agent-credentials" {
  metadata {
    name = "iot-agent-credentials"
  }

  data = {
    mongo_user     = var.mongodb_iot_agent_username
    mongo_password = var.mongodb_iot_agent_password
  }

  type = "Opaque"
}

resource "kubernetes_service" "amqp" {
  metadata {
    name = "amqp"
  }
  spec {
    selector = {
      name = kubernetes_deployment.amqp-and-iot-agent.metadata[0].labels.name
    }
    port {
      port = 3000
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_service" "iot-agent" {
  metadata {
    name = "iot-agent"
  }
  spec {
    selector = {
      name = kubernetes_deployment.amqp-and-iot-agent.metadata[0].labels.name
    }
    port {
      name = "north-port"
      port = 4041
    }
    port {
      name = "http-port"
      port = 7896
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "amqp-and-iot-agent" {
  metadata {
    name = "iot-agent"
    labels = {
      name = "amqp-and-iot-agent"
    }
  }

  spec {
    replicas = var.amqp10-converter_and_iotagent_replicas

    selector {
      match_labels = {
        name = "amqp-and-iot-agent"
      }
    }

    template {
      metadata {
        labels = {
          name = "amqp-and-iot-agent"
        }
      }

      spec {
        container {
          image = var.amqp10-converter_image_name
          name  = "amqp10-converter"

          resources {
            requests {
              cpu    = "250m"
              memory = "128Mi"
            }
          }

          port {
            container_port = 3000
          }

          env {
            name  = "AMQP_HOST"
            value = "${azurerm_servicebus_namespace.sb.name}.servicebus.windows.net"
          }

          env {
            name  = "AMQP_PORT"
            value = 5671
          }

          env {
            name  = "AMQP_USE_TLS"
            value = true
          }

          env {
            name = "AMQP_USERNAME"
            value_from {
              secret_key_ref {
                name = "servicebus-credentials"
                key  = "ruleName"
              }
            }
          }

          env {
            name = "AMQP_PASSWORD"
            value_from {
              secret_key_ref {
                name = "servicebus-credentials"
                key  = "primaryKey"
              }
            }
          }

          env {
            name  = "IOTA_HOST"
            value = "iot-agent.default.svc.cluster.local"
          }

          env {
            name  = "IOTA_MANAGE_PORT"
            value = 4041
          }

          env {
            name  = "IOTA_DATA_PORT"
            value = 7896
          }

          env {
            name  = "IOTA_CB_HOST"
            value = "orion.default.svc.cluster.local"
          }

          env {
            name  = "IOTA_CB_PORT"
            value = 1026
          }

          env {
            name  = "IOTA_CB_NGSI_VERSION"
            value = "v2"
          }

          env {
            name  = "USE_FULLY_QUALIFIED_QUEUE_NAME"
            value = false
          }

          env {
            name  = "UPSTREAM_DATA_MODEL"
            value = "dm-by-entity"
          }

          env {
            name  = "FIWARE_SERVICE"
            value = ""
          }

          env {
            name  = "FIWARE_SERVICEPATH"
            value = "/"
          }

          env {
            name  = "QUEUE_DEFS"
            value = "[{\"type\":\"robot\", \"id\":\"robot01\"}]"
          }

          env {
            name  = "SCHEMA_PATHS"
            value = "{\"robot\\\\.robot01\\\\.up\":[]}"
          }

          env {
            name  = "LOG_LEVEL"
            value = var.amqp10-converter_log_level
          }

          liveness_probe {
            tcp_socket {
              port = 4041
            }
            failure_threshold = 12
            period_seconds    = 10
          }

          readiness_probe {
            tcp_socket {
              port = 4041
            }
            failure_threshold = 12
            period_seconds    = 10
          }
        }

        container {
          image = var.iotagent_image_name
          name  = "iot-agent"

          resources {
            requests {
              cpu    = "250m"
              memory = "128Mi"
            }
          }

          port {
            name           = "north-port"
            container_port = 4041
          }

          port {
            name           = "http-port"
            container_port = 7896
          }

          env {
            name  = "IOTA_CB_HOST"
            value = "orion.default.svc.cluster.local"
          }

          env {
            name  = "IOTA_CB_PORT"
            value = 1026
          }

          env {
            name  = "IOTA_CB_NGSI_VERSION"
            value = "v2"
          }

          env {
            name  = "IOTA_AUTOCAST"
            value = true
          }

          env {
            name  = "IOTA_TIMESTAMP"
            value = true
          }

          env {
            name  = "IOTA_REGISTRY_TYPE"
            value = "mongodb"
          }

          env {
            name  = "IOTA_MONGO_HOST"
            value = var.mongodb_host
          }

          env {
            name  = "IOTA_MONGO_PORT"
            value = 27017
          }

          env {
            name  = "IOTA_MONGO_REPLICASET"
            value = var.mongodb_rsname
          }

          env {
            name  = "IOTA_MONGO_SSL"
            value = true
          }

          env {
            name  = "IOTA_MONGO_AUTH_SOURCE"
            value = var.mongodb_authdb
          }

          env {
            name  = "IOTA_MONGO_DB"
            value = var.mongodb_iot_agent_database_name
          }

          env {
            name = "IOTA_MONGO_USER"
            value_from {
              secret_key_ref {
                name = "iot-agent-credentials"
                key  = "mongo_user"
              }
            }
          }

          env {
            name = "IOTA_MONGO_PASSWORD"
            value_from {
              secret_key_ref {
                name = "iot-agent-credentials"
                key  = "mongo_password"
              }
            }
          }

          env {
            name  = "IOTA_NORTH_PORT"
            value = 4041
          }

          env {
            name  = "IOTA_HTTP_PORT"
            value = 7896
          }

          env {
            name  = "IOTA_PROVIDER_URL"
            value = "http://iot-agent.default.svc.cluster.local:4041"
          }

          env {
            name  = "IOTA_LOG_LEVEL"
            value = var.iotagent_loglevel
          }
        }

        volume {
          name = "config-schema-security"
          config_map {
            name = "amqp-config-schema-security"
          }
        }

      }
    }
  }
}

