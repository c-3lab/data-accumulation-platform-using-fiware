resource "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_workspace_name
  location            = azurerm_resource_group.IoT-Platform.location
  resource_group_name = azurerm_resource_group.IoT-Platform.name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_workspace_retention_in_days
  tags = {
    source = var.terraform-tag
  }
}

resource "azurerm_monitor_diagnostic_setting" "law" {
  name                       = var.log_analytics_workspace_diag_name
  target_resource_id         = azurerm_log_analytics_workspace.law.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "Audit"
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

  depends_on = [
    azurerm_log_analytics_workspace.law
  ]
}
