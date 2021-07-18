resource "azurerm_postgresql_server" "psql" {
  name                = var.psql_server_name
  location            = "Japan West"
  resource_group_name = azurerm_resource_group.IoT-Platform.name

  administrator_login          = var.psql_admin_user
  administrator_login_password = var.psql_admin_password

  sku_name   = var.psql_server_sku_name
  version    = var.psql_server_version
  storage_mb = var.psql_server_storage_mb

  backup_retention_days        = var.psql_server_backup_retention_days
  auto_grow_enabled            = var.psql_server_auto_grow_enabled
  geo_redundant_backup_enabled = var.psql_server_geo_redundant_backup_enabled

  public_network_access_enabled    = var.psql_server_public_network_access_enabled
  ssl_enforcement_enabled          = var.psql_server_ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced = var.psql_server_ssl_minimal_tls_version_enforced

  tags = {
    source = var.terraform-tag
  }

  lifecycle {
    ignore_changes = [administrator_login_password, storage_mb]
  }
}

# Defined "local._aks_resource_group_name" by kubernetes_service.tf.
data "azurerm_public_ip" "aks-output-ip" {
  name                = split("/", data.azurerm_lb.kubernetes-lb.frontend_ip_configuration[0].public_ip_address_id)[8]
  resource_group_name = local._aks_resource_group_name

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "azurerm_postgresql_firewall_rule" "aks-output-lb" {
  name                = var.psql_firewall_rule_loadbalancer
  resource_group_name = azurerm_resource_group.IoT-Platform.name
  server_name         = azurerm_postgresql_server.psql.name
  start_ip_address    = data.azurerm_public_ip.aks-output-ip.ip_address
  end_ip_address      = data.azurerm_public_ip.aks-output-ip.ip_address

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

### Log diagnostic setting
resource "azurerm_postgresql_configuration" "psql_pg_qs_query_capture_mode" {
  name                = "pg_qs.query_capture_mode"
  resource_group_name = azurerm_postgresql_server.psql.resource_group_name
  server_name         = azurerm_postgresql_server.psql.name
  value               = "TOP"
}

resource "azurerm_postgresql_configuration" "psql_pgms_wait_sampling_query_capture_mode" {
  name                = "pgms_wait_sampling.query_capture_mode"
  resource_group_name = azurerm_postgresql_server.psql.resource_group_name
  server_name         = azurerm_postgresql_server.psql.name
  value               = "ALL"
}

resource "azurerm_postgresql_configuration" "psql_pg_qs_retention_period_in_days" {
  name                = "pg_qs.retention_period_in_days"
  resource_group_name = azurerm_postgresql_server.psql.resource_group_name
  server_name         = azurerm_postgresql_server.psql.name
  value               = "30"
}

resource "azurerm_monitor_diagnostic_setting" "psql" {
  name                       = var.psql_diag_name
  target_resource_id         = azurerm_postgresql_server.psql.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "PostgreSQLLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }

  log {
    category = "QueryStoreRuntimeStatistics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }

  log {
    category = "QueryStoreWaitStatistics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }
}
