resource "azurerm_servicebus_namespace" "service_bus" {
  location            = azurerm_resource_group.resource_group.location
  name                = "servicebus"
  resource_group_name = azurerm_resource_group.resource_group.name
  sku                 = "Standard"
}