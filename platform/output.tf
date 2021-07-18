output "service_bus_name" {
  value = azurerm_servicebus_namespace.sb.name
}

output "service_bus_resource_group_name" {
  value = azurerm_servicebus_namespace.sb.resource_group_name
}
