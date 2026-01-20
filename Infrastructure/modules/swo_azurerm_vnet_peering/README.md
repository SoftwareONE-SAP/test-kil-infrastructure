# swo_azurerm_vnet_peering

## Purpose
This module creates an Azure VNet Peering connection between two Virtual Networks using an object-based input pattern. It is designed for reuse across multiple environments and adheres to the Unified Master Terraform Coding Standards.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| peering_config | object | Primary configuration object for the VNet Peering. | Yes |

### peering_config Object Schema

```hcl
{
  name                          = string
  resource_group_name           = string
  virtual_network_name          = string
  remote_virtual_network_id     = string
  allow_virtual_network_access  = optional(bool, true)
  allow_forwarded_traffic       = optional(bool, false)
  allow_gateway_transit         = optional(bool, false)
  use_remote_gateways           = optional(bool, false)
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the VNet Peering. |
| name | The Name of the VNet Peering. |

## Usage Example

```hcl
module "hub_to_spoke_peering" {
  source = "../../modules/swo_azurerm_vnet_peering"

  peering_config = {
    name                          = "peer-hub-to-spoke"
    resource_group_name           = "rg-hub-prod-weu-01"
    virtual_network_name          = "vnet-hub-prod-weu-01"
    remote_virtual_network_id     = module.spoke_vnet.id
    allow_virtual_network_access  = true
    allow_forwarded_traffic       = true
    allow_gateway_transit         = true
    use_remote_gateways           = false
  }
}
```

## Notes
- The Peering name must start with `peer-` as enforced by the validation rule.
- This module creates a one-way peering. For bidirectional peering, create two instances of this module (one in each direction).
