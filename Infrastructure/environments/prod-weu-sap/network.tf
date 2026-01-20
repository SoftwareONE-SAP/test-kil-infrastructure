resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = local.location
  tags     = local.tags
}

# Create VNets
module "hub_vnet" {
  source = "../../modules/swo_azurerm_vnet"

  vnet_config = {
    name                = local.hub_vnet_name
    location            = local.location
    resource_group_name = azurerm_resource_group.this.name
    address_space       = local.vnets[local.hub_vnet_name].address_space
    tags                = local.tags
  }
}

module "spoke_vnet" {
  source = "../../modules/swo_azurerm_vnet"

  vnet_config = {
    name                = local.spoke_vnet_name
    location            = local.location
    resource_group_name = azurerm_resource_group.this.name
    address_space       = local.vnets[local.spoke_vnet_name].address_space
    tags                = local.tags
  }
}

# Create Subnets
module "hub_subnets" {
  for_each = local.vnets[local.hub_vnet_name].subnets
  source   = "../../modules/swo_azurerm_subnet"

  subnet_config = {
    name                 = each.key
    resource_group_name  = azurerm_resource_group.this.name
    virtual_network_name = module.hub_vnet.name
    address_prefixes     = each.value.address_prefixes
    service_endpoints    = lookup(each.value, "service_endpoints", [])
    delegation           = lookup(each.value, "delegation", {})
    tags                 = local.tags
  }
}

module "spoke_subnets" {
  for_each = local.vnets[local.spoke_vnet_name].subnets
  source   = "../../modules/swo_azurerm_subnet"

  subnet_config = {
    name                 = each.key
    resource_group_name  = azurerm_resource_group.this.name
    virtual_network_name = module.spoke_vnet.name
    address_prefixes     = each.value.address_prefixes
    service_endpoints    = lookup(each.value, "service_endpoints", [])
    delegation           = lookup(each.value, "delegation", {})
    tags                 = local.tags
  }
}

# Create NSGs
module "app_nsg" {
  source = "../../modules/swo_azurerm_nsg"

  nsg_config = {
    name                = "nsg-app-prod-weu-01"
    location            = local.location
    resource_group_name = azurerm_resource_group.this.name
    tags                = local.tags
  }

  security_rules = local.nsg_rules["app-nsg"].rules
}

module "db_nsg" {
  source = "../../modules/swo_azurerm_nsg"

  nsg_config = {
    name                = "nsg-db-prod-weu-01"
    location            = local.location
    resource_group_name = azurerm_resource_group.this.name
    tags                = local.tags
  }

  security_rules = local.nsg_rules["db-nsg"].rules
}

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = module.spoke_subnets["snet-app-prod-weu-01"].id
  network_security_group_id = module.app_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = module.spoke_subnets["snet-db-prod-weu-01"].id
  network_security_group_id = module.db_nsg.id
}

# Create Route Table
module "sap_route_table" {
  source = "../../modules/swo_azurerm_route_table"

  route_table_config = {
    name                = "rt-sap-spoke"
    location            = local.location
    resource_group_name = azurerm_resource_group.this.name
    tags                = local.tags
  }

  routes = local.route_table["sap-spoke-rt"].routes
}

# Associate Route Table with Subnets
resource "azurerm_subnet_route_table_association" "app" {
  subnet_id      = module.spoke_subnets["snet-app-prod-weu-01"].id
  route_table_id = module.sap_route_table.id
}

resource "azurerm_subnet_route_table_association" "db" {
  subnet_id      = module.spoke_subnets["snet-db-prod-weu-01"].id
  route_table_id = module.sap_route_table.id
}

# Create VNet Peering
module "hub_to_spoke_peering" {
  source = "../../modules/swo_azurerm_vnet_peering"

  peering_config = {
    name                          = "peer-hub-to-spoke"
    resource_group_name           = azurerm_resource_group.this.name
    virtual_network_name          = module.hub_vnet.name
    remote_virtual_network_id     = module.spoke_vnet.id
    allow_virtual_network_access  = true
    allow_forwarded_traffic       = true
    allow_gateway_transit         = true
    use_remote_gateways           = false
  }
}

module "spoke_to_hub_peering" {
  source = "../../modules/swo_azurerm_vnet_peering"

  peering_config = {
    name                          = "peer-spoke-to-hub"
    resource_group_name           = azurerm_resource_group.this.name
    virtual_network_name          = module.spoke_vnet.name
    remote_virtual_network_id     = module.hub_vnet.id
    allow_virtual_network_access  = true
    allow_forwarded_traffic       = true
    allow_gateway_transit         = false
    use_remote_gateways           = true
  }
}