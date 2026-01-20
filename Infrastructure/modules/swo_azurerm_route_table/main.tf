resource "azurerm_route_table" "this" {
  name                = var.route_table_config.name
  location            = var.route_table_config.location
  resource_group_name = var.route_table_config.resource_group_name
  tags                = var.route_table_config.tags
}

resource "azurerm_route" "this" {
  for_each                = var.routes
  name                    = each.value.name
  resource_group_name     = var.route_table_config.resource_group_name
  route_table_name        = azurerm_route_table.this.name
  address_prefix          = each.value.address_prefix
  next_hop_type           = each.value.next_hop_type
  next_hop_in_ip_address  = each.value.next_hop_in_ip_address
}