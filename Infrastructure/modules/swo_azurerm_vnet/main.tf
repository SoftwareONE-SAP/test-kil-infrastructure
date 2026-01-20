resource "azurerm_virtual_network" "this" {
  name                = var.vnet_config.name
  location            = var.vnet_config.location
  resource_group_name = var.vnet_config.resource_group_name
  address_space       = var.vnet_config.address_space
  tags                = var.vnet_config.tags
}