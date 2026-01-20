# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

# Virtual Networks
resource "azurerm_virtual_network" "vnets" {
  for_each = local.vnets

  name                = each.key
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = each.value.address_space
  tags                = local.tags
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = merge([
    for vnet_key, vnet in local.vnets : {
      for subnet_key, subnet in vnet.subnets :
      "${vnet_key}/${subnet_key}" => merge(subnet, {
        vnet_name = vnet_key
      })
    }
  ]...)

  name                 = split("/", each.key)[1]
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = each.value.vnet_name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = try(each.value.service_endpoints, [])
}

# Network Security Groups
resource "azurerm_network_security_group" "jump" {
  name                = "nsg-jump-${var.environment}-${local.region_code}-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "jump" {
  for_each = local.nsg_rules_jump

  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.jump.name
}

resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${var.environment}-${local.region_code}-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "app" {
  for_each = local.nsg_rules_app

  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.app.name
}

resource "azurerm_network_security_group" "db" {
  name                = "nsg-db-${var.environment}-${local.region_code}-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "db" {
  for_each = local.nsg_rules_db

  name                        = each.key
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.db.name
}

# NSG to Subnet Associations
resource "azurerm_subnet_network_security_group_association" "jump" {
  subnet_id                 = azurerm_subnet.subnets["${local.hub_vnet_name}/snet-jump-${var.environment}-${local.region_code}-01"].id
  network_security_group_id = azurerm_network_security_group.jump.id
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.subnets["${local.spoke_vnet_name}/snet-app-${var.environment}-${local.region_code}-01"].id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.subnets["${local.spoke_vnet_name}/snet-db-${var.environment}-${local.region_code}-01"].id
  network_security_group_id = azurerm_network_security_group.db.id
}

# Route Tables
resource "azurerm_route_table" "spoke" {
  name                = "rt-${local.project}-spoke-${var.environment}-${local.region_code}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_route" "spoke_routes" {
  for_each = local.route_tables["rt-${local.project}-spoke-${var.environment}-${local.region_code}"].routes

  name                   = each.key
  resource_group_name    = azurerm_resource_group.main.name
  route_table_name       = azurerm_route_table.spoke.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = try(each.value.next_hop_in_ip_address, null)
}

# Route Table to Subnet Associations
resource "azurerm_subnet_route_table_association" "app" {
  subnet_id      = azurerm_subnet.subnets["${local.spoke_vnet_name}/snet-app-${var.environment}-${local.region_code}-01"].id
  route_table_id = azurerm_route_table.spoke.id
}

resource "azurerm_subnet_route_table_association" "db" {
  subnet_id      = azurerm_subnet.subnets["${local.spoke_vnet_name}/snet-db-${var.environment}-${local.region_code}-01"].id
  route_table_id = azurerm_route_table.spoke.id
}

# VNet Peering
resource "azurerm_virtual_network_peering" "peerings" {
  for_each = local.vnet_peerings

  name                         = each.key
  resource_group_name          = azurerm_resource_group.main.name
  virtual_network_name         = each.value.source_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.vnets[each.value.destination_vnet_name].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways

  depends_on = [
    azurerm_virtual_network.vnets
  ]
}
