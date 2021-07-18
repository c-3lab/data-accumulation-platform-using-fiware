resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.IoT-Platform.location
  resource_group_name      = azurerm_resource_group.IoT-Platform.name
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  access_tier              = var.storage_account_access_tier

  tags = {
    source = var.terraform-tag
  }
}

