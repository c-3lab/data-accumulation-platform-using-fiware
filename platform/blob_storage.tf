resource "azurerm_storage_container" "sac" {
  name                  = var.blob_storage_container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = var.blob_storage_container_container_access_type
}
