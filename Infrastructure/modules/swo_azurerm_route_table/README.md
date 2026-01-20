# swo_azurerm_route_table

## Purpose
This module creates an Azure Route Table and applies a set of routes using an object-based input pattern. It is designed for reuse across multiple environments and adheres to the Unified Master Terraform Coding Standards.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| route_table_config | object | Primary configuration object for the Route Table. | Yes |
| routes | map(object) | Map of routes to apply to the Route Table. | No |

### route_table_config Object Schema

```hcl
{
  name                = string
  location            = string
  resource_group_name = string
  tags                = optional(map(string), {})
}
```

### routes Map Schema

```hcl
{
  name                   = string
  address_prefix         = string
  next_hop_type          = string
  next_hop_in_ip_address = optional(string)
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the Route Table. |
| name | The Name of the Route Table. |
| route_ids | Map of route IDs by route name. |

## Usage Example

```hcl
module "sap_route_table" {
  source = "../../modules/swo_azurerm_route_table"

  route_table_config = {
    name                = "rt-sap-spoke"
    location            = "westeurope"
    resource_group_name = "rg-hub-prod-weu-01"
    tags = {
      Environment = "Production"
      Owner       = "SAP Team"
    }
  }

  routes = {
    "default" = {
      name                   = "default"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.222.214.4"
    }
  }
}
```

## Notes
- The Route Table name must start with `rt-` as enforced by the validation rule.
- This module does not associate the Route Table with subnets. Use the `azurerm_subnet_route_table_association` resource in your environment code to associate Route Tables with subnets.
