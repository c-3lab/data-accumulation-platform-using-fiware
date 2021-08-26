resource "random_string" "log_migration_sp_password" {
  keepers = {
    env_name = "TF_LOG_MIGRATION_SP_PASSWORD"
  }
  length           = 24
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  special          = true
  min_special      = 1
  override_special = "!@-_=+."
}

resource "random_string" "log_migration_sp_secret" {
  keepers = {
    env_name = "TF_LOG_MIGRATION_SP_SECRET"
  }
  length           = 24
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  special          = true
  min_special      = 1
  override_special = "!@-_=+."
}

resource "azuread_application" "log_migration_sp" {
  name = var.azuread_application_function_log-migration_name
}

resource "azuread_service_principal" "log_migration_sp" {
  application_id               = azuread_application.log_migration_sp.application_id
  app_role_assignment_required = false
}

resource "azuread_service_principal_password" "log_migration_sp" {
  service_principal_id = azuread_service_principal.log_migration_sp.id
  value                = random_string.log_migration_sp_password.result
  end_date_relative    = "8760h"

  lifecycle {
    ignore_changes = [
      value,
      end_date_relative
    ]
  }
}

resource "azuread_application_password" "log_migration_sp" {
  application_object_id = azuread_application.log_migration_sp.id
  value                 = random_string.log_migration_sp_secret.result
  end_date_relative     = "8760h"

  lifecycle {
    ignore_changes = [
      value,
      end_date_relative
    ]
  }
}

resource "azurerm_role_assignment" "log_migration_sp_monitoring_contributor" {
  scope                = azurerm_log_analytics_workspace.law.id
  role_definition_name = "Monitoring Contributor"
  principal_id         = azuread_service_principal.log_migration_sp.object_id
}

resource "azurerm_role_assignment" "log_migration_sp_storage_blob_data_contributor" {
  scope                = azurerm_storage_container.sac.resource_manager_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.log_migration_sp.object_id
}

data "azurerm_function_app" "LogManipulator" {
  name                = var.function_app_log-migration_name
  resource_group_name = azurerm_resource_group.IoT-Platform.name
}

resource "azurerm_monitor_diagnostic_setting" "LogManipulator" {
  name                       = var.function_app_log-migration_diag_name
  target_resource_id         = data.azurerm_function_app.LogManipulator.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "FunctionAppLogs"
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
    data.azurerm_function_app.LogManipulator
  ]
}

