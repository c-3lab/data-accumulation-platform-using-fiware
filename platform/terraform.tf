terraform {
  required_version = "0.13.4"
  required_providers {
    azuread    = "0.11.0"
    azurerm    = "2.22.0"
    kubernetes = "1.12.0"
    random   = "2.3.0"
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "Data-Accumulation-Platform"
    storage_account_name = "DataAccumulationPlatform"
    container_name       = "data-accumulation-platform"
    key                  = "dev.platform.terraform.tfstate"
  }
}

resource "azurerm_resource_group" "IoT-Platform" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    source = var.terraform-tag
  }

}