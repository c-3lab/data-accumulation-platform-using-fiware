resource "azurerm_container_registry" "acr" {
  name                = var.container_registry_name
  location            = azurerm_resource_group.IoT-Platform.location
  resource_group_name = azurerm_resource_group.IoT-Platform.name
  sku                 = var.container_registry_sku
  admin_enabled       = var.container_registry_admin_enabled
  tags = {
    source = var.terraform-tag
  }
}

### Log diagnostic setting
resource "azurerm_monitor_diagnostic_setting" "acr" {
  name                       = var.container_registry_diag_name
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "ContainerRegistryRepositoryEvents"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }

  log {
    category = "ContainerRegistryLoginEvents"
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
