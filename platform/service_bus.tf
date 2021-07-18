resource "azurerm_servicebus_namespace" "sb" {
  name                = var.servicebus_namespace_name
  location            = azurerm_resource_group.IoT-Platform.location
  resource_group_name = azurerm_resource_group.IoT-Platform.name
  sku                 = var.servicebus_sku
  tags = {
    source = var.terraform-tag
  }
}

resource "azurerm_servicebus_namespace_authorization_rule" "amqp10-converter" {
  name                = var.servicebus_auth_rule_name_amqp10-converter
  resource_group_name = azurerm_servicebus_namespace.sb.resource_group_name
  namespace_name      = azurerm_servicebus_namespace.sb.name

  listen = true
  send   = true
  manage = false
}

### Log diagnostic setting
resource "azurerm_monitor_diagnostic_setting" "service-bus" {
  name                       = var.servicebus_diag_name
  target_resource_id         = azurerm_servicebus_namespace.sb.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "OperationalLogs"
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
