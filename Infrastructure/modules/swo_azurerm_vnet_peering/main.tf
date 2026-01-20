resource "azurerm_virtual_network_peering" "this" {
  name                          = var.peering_config.name
  resource_group_name           = var.peering_config.resource_group_name
  virtual_network_name          = var.peering_config.virtual_network_name
  remote_virtual_network_id     = var.peering_config.remote_virtual_network_id
  allow_virtual_network_access  = var.peering_config.allow_virtual_network_access
  allow_forwarded_traffic       = var.peering_config.allow_forwarded_traffic
  allow_gateway_transit         = var.peering_config.allow_gateway_transit
  use_remote_gateways           = var.peering_config.use_remote_gateways
}