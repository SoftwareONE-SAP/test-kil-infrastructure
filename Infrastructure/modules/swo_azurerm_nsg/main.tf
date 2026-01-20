resource "azurerm_network_security_group" "this" {
  name                = var.nsg_config.name
  location            = var.nsg_config.location
  resource_group_name = var.nsg_config.resource_group_name
  tags                = var.nsg_config.tags
}

resource "azurerm_network_security_rule" "this" {
  for_each                = var.security_rules
  name                       = each.value.name
  priority                   = each.value.priority
  direction                  = each.value.direction
  access                     = each.value.access
  protocol                   = each.value.protocol
  source_port_range          = each.value.source_port_range
  source_port_ranges         = each.value.source_port_ranges
  destination_port_range     = each.value.destination_port_range
  destination_port_ranges    = each.value.destination_port_ranges
  source_address_prefix      = each.value.source_address_prefix
  source_address_prefixes    = each.value.source_address_prefixes
  destination_address_prefix = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
  resource_group_name         = var.nsg_config.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}