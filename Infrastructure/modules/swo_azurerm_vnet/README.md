# swo_azurerm_vnet

## Purpose
This module creates a single Azure Virtual Network (VNet) using an object-based input pattern. It is designed for reuse across multiple environments and adheres to the Unified Master Terraform Coding Standards.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| vnet_config | object | Primary configuration object for the Virtual Network. | Yes |

### vnet_config Object Schema

```hcl
{
  name                = string
  location            = string
  resource_group_name = string
  address_space       = list(string)
  tags                = optional(map(string), {})
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the Virtual Network. |
| name | The Name of the Virtual Network. |
| address_space | The address space of the Virtual Network. |

## Usage Example

```hcl
module "hub_vnet" {
  source = "../../modules/swo_azurerm_vnet"

  vnet_config = {
    name                = "vnet-hub-prod-weu-01"
    location            = "westeurope"
    resource_group_name = "rg-hub-prod-weu-01"
    address_space       = ["10.222.212.0/22"]
    tags = {
      Environment = "Production"
      Owner       = "SAP Team"
    }
  }
}
```

## Notes
- The VNet name must start with `vnet-` as enforced by the validation rule.
- This module does not create subnets. Use the `swo_azurerm_subnet` module for subnet creation.
