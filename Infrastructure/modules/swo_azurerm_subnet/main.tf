resource "azurerm_subnet" "this" {
  name                 = var.subnet_config.name
  resource_group_name  = var.subnet_config.resource_group_name
  virtual_network_name = var.subnet_config.virtual_network_name
  address_prefixes     = var.subnet_config.address_prefixes

  dynamic "delegation" {
    for_each = var.subnet_config.delegation
    content {
      name = delegation.key
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }

  service_endpoints = var.subnet_config.service_endpoints
}