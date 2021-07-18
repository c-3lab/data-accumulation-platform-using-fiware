resource "random_string" "aks_sp_password" {
  keepers = {
    env_name = "TF_AKS_SP_PASSWORD"
  }
  length           = 24
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  special          = true
  min_special      = 1
  override_special = "!@-_=+."
}

resource "random_string" "aks_sp_secret" {
  keepers = {
    env_name = "TF_AKS_SP_SECRET"
  }
  length           = 24
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  special          = true
  min_special      = 1
  override_special = "!@-_=+."
}

resource "azuread_application" "aks_sp" {
  name = var.azuread_application_kubernetes_name
}

resource "azuread_service_principal" "aks_sp" {
  application_id               = azuread_application.aks_sp.application_id
  app_role_assignment_required = false
}

resource "azuread_service_principal_password" "aks_sp" {
  service_principal_id = azuread_service_principal.aks_sp.id
  value                = random_string.aks_sp_password.result
  end_date_relative    = "8760h"

  lifecycle {
    ignore_changes = [
      value,
      end_date_relative
    ]
  }
}

resource "azuread_application_password" "aks_sp" {
  application_object_id = azuread_application.aks_sp.id
  value                 = random_string.aks_sp_secret.result
  end_date_relative     = "8760h"

  lifecycle {
    ignore_changes = [
      value,
      end_date_relative
    ]
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.kubernetes_resource_name
  location            = azurerm_resource_group.IoT-Platform.location
  resource_group_name = azurerm_resource_group.IoT-Platform.name
  dns_prefix          = var.kubernetes_dns_prefix_name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = var.kubernetes_node_pool_name
    node_count      = var.kubernetes_node_count
    vm_size         = var.kubernetes_node_vm_size
    os_disk_size_gb = var.kubernetes_node_disk_size
    tags = {
      source = var.terraform-tag
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "Standard"
  }

  service_principal {
    client_id     = azuread_service_principal.aks_sp.application_id
    client_secret = random_string.aks_sp_password.result
  }

  addon_profile {
    kube_dashboard {
      enabled = true
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
    }
  }

  tags = {
    source = var.terraform-tag
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "aks_sp_container_registry" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.aks_sp.object_id
}

resource "azurerm_monitor_diagnostic_setting" "kubernetes" {
  name                       = var.kubernetes_diag_name
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "kube-apiserver"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }

  log {
    category = "kube-audit"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }

  log {
    category = "kube-audit-admin"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }

  log {
    category = "guard"
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
    azurerm_kubernetes_cluster.aks
  ]
}

# Define variable for created resource group name by AKS.
locals {
  _platform_rg             = azurerm_resource_group.IoT-Platform.name
  _aks_name                = azurerm_kubernetes_cluster.aks.name
  _location                = azurerm_kubernetes_cluster.aks.location
  _aks_resource_group_name = "mc_${local._platform_rg}_${local._aks_name}_${local._location}"
}

data "azurerm_lb" "kubernetes-lb" {
  name                = "kubernetes"
  resource_group_name = local._aks_resource_group_name

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "azurerm_monitor_diagnostic_setting" "kubernetes-lb" {
  name                       = "LoadBalancer_Logs"
  target_resource_id         = data.azurerm_lb.kubernetes-lb.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "LoadBalancerAlertEvent"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 181
    }
  }

  log {
    category = "LoadBalancerProbeHealthStatus"
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
    azurerm_kubernetes_cluster.aks
  ]
}
