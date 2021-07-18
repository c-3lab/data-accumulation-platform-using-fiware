resource "kubernetes_secret" "kong-gateway-credentials" {
  metadata {
    name = "kong-gateway-credentials"
  }

  data = {
    postgresql_user     = "${var.psql_kong_user}@${azurerm_postgresql_server.psql.name}"
    postgresql_password = var.psql_kong_password
  }

  type = "Opaque"
}

# This block is to store custom ssl certificate and ssl key file.
# Uncomment following block, if use custom certificate and ssl key file at Kong-gateway.
resource "kubernetes_secret" "kong-gateway-tls-credentials" {
  metadata {
    name = "kong-gateway-tls-credentials"
  }

  data = {
    "tls.crt" = file("certs/fullchain.pem")
    "tls.key" = file("certs/privkey.pem")
  }

  type = "kubernetes.io/tls"
}

# Listen public ip address for Kong-gateway
resource "azurerm_public_ip" "kong-gateway" {
  name                = var.kong_public_ip_name
  resource_group_name = local._aks_resource_group_name
  location            = azurerm_kubernetes_cluster.aks.location
  allocation_method   = "Static"
  sku                 = azurerm_kubernetes_cluster.aks.network_profile[0].load_balancer_sku
  domain_name_label   = var.kong_public_ip_domain_name

  tags = {
    source = var.terraform-tag
  }
}

resource "kubernetes_service" "kong-gateway" {
  metadata {
    name = "kong-gateway"
  }

  spec {
    selector = {
      name = kubernetes_deployment.kong-gateway.spec[0].template[0].spec[0].container.0.name
    }

    port {
      name = "proxy"
      port = 8000
    }

    port {
      name = "admin-api"
      port = 8001
    }

    port {
      name = "admin-api-ssl"
      port = 8444
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "kong-gateway-external" {
  metadata {
    name = "kong-gateway-external"
  }

  spec {
    selector = {
      name = kubernetes_deployment.kong-gateway.spec[0].template[0].spec[0].container.0.name
    }

    port {
      name        = "proxy-ssl"
      target_port = 8443
      port        = 443
    }

    type             = "LoadBalancer"
    load_balancer_ip = azurerm_public_ip.kong-gateway.ip_address
  }
}

resource "kubernetes_deployment" "kong-gateway" {
  metadata {
    name = "kong-gateway"
    labels = {
      name = "kong-gateway"
    }
  }

  spec {
    replicas = var.kong_replicas

    selector {
      match_labels = {
        name = "kong-gateway"
      }
    }

    template {
      metadata {
        labels = {
          name = "kong-gateway"
        }
      }

      spec {
        # Initialize database for Kong gateway.
        init_container {
          image = var.kong_image_name
          name  = "init-kong-gateway"

          resources {
            requests {
              cpu    = "250m"
              memory = "128Mi"
            }
          }

          env {
            name  = "KONG_PG_HOST"
            value = azurerm_postgresql_server.psql.fqdn
          }

          env {
            name  = "KONG_DATABASE"
            value = "postgres"
          }

          env {
            name  = "KONG_PG_SSL"
            value = "on"
          }

          env {
            name = "KONG_PG_USER"
            value_from {
              secret_key_ref {
                name = "kong-gateway-credentials"
                key  = "postgresql_user"
              }
            }
          }

          env {
            name = "KONG_PG_PASSWORD"
            value_from {
              secret_key_ref {
                name = "kong-gateway-credentials"
                key  = "postgresql_password"
              }
            }
          }

          env {
            name  = "KONG_CASSANDRA_CONTACT_POINTS"
            value = azurerm_postgresql_server.psql.fqdn
          }

          env {
            name  = "KONG_PROXY_ACCESS_LOG"
            value = "/dev/stdout"
          }

          env {
            name  = "KONG_ADMIN_ACCESS_LOG"
            value = "/dev/stdout"
          }

          env {
            name  = "KONG_PROXY_ERROR_LOG"
            value = "/dev/stderr"
          }

          env {
            name  = "KONG_ADMIN_ERROR_LOG"
            value = "/dev/stderr"
          }

          args = [
            "kong",
            "migrations",
            "bootstrap"
          ]

        }

        # Kong gateway (Main container)
        container {
          image = var.kong_image_name
          name  = "kong-gateway"

          resources {
            requests {
              cpu    = "250m"
              memory = "128Mi"
            }
          }

          port {
            name           = "proxy"
            container_port = 8000
          }

          port {
            name           = "proxy-ssl"
            container_port = 8443
          }

          port {
            name           = "admin-api"
            container_port = 8001
          }

          port {
            name           = "admin-api-ssl"
            container_port = 8444
          }

          env {
            name  = "KONG_PG_HOST"
            value = azurerm_postgresql_server.psql.fqdn
          }

          env {
            name  = "KONG_DATABASE"
            value = "postgres"
          }

          env {
            name  = "KONG_PG_SSL"
            value = "on"
          }

          env {
            name = "KONG_PG_USER"
            value_from {
              secret_key_ref {
                name = "kong-gateway-credentials"
                key  = "postgresql_user"
              }
            }
          }

          env {
            name = "KONG_PG_PASSWORD"
            value_from {
              secret_key_ref {
                name = "kong-gateway-credentials"
                key  = "postgresql_password"
              }
            }
          }

          env {
            name  = "KONG_CASSANDRA_CONTACT_POINTS"
            value = azurerm_postgresql_server.psql.fqdn
          }

          env {
            name  = "KONG_PROXY_ACCESS_LOG"
            value = "/dev/stdout"
          }

          env {
            name  = "KONG_ADMIN_ACCESS_LOG"
            value = "/dev/stdout"
          }

          env {
            name  = "KONG_PROXY_ERROR_LOG"
            value = "/dev/stderr"
          }

          env {
            name  = "KONG_ADMIN_ERROR_LOG"
            value = "/dev/stderr"
          }

          env {
            name  = "KONG_ADMIN_LISTEN"
            value = "0.0.0.0:8001, 0.0.0.0:8444 ssl"
          }

          # Uncomment following environment variable, if use ssl certificate.
          # The absolute path to the SSL certificate. 
          env {
            name  = "KONG_SSL_CERT"
            value = "/tmp/ssl_certs/tls.crt"
          }

          # Uncomment following environment variable, if use ssl certificate.
          # The absolute path to the SSL key. 
          env {
            name  = "KONG_SSL_CERT_KEY"
            value = "/tmp/ssl_certs/tls.key"
          }

          # Uncomment following block, if use custom certificate and ssl key file at Kong-gateway.
          volume_mount {
            name       = "kong-gatewa-ssl-certs"
            mount_path = "/tmp/ssl_certs"
            read_only  = true
          }

          liveness_probe {
            tcp_socket {
              port = 8001
            }
            failure_threshold     = 12
            period_seconds        = 10
            initial_delay_seconds = 5
          }

          readiness_probe {
            tcp_socket {
              port = 8001
            }
            failure_threshold     = 12
            period_seconds        = 10
            initial_delay_seconds = 5
          }
        }

        # Uncomment following block, if use custom certificate and ssl key file at Kong-gateway.
        volume {
          name = "kong-gatewa-ssl-certs"
          secret {
            secret_name = "kong-gateway-tls-credentials"
          }
        }
      }
    }
  }
}
