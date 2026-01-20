# swo_azurerm_subnet

## Purpose
This module creates a single Azure Subnet within a Virtual Network using an object-based input pattern. It supports service endpoints, delegation, and is designed for reuse across multiple environments.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| subnet_config | object | Primary configuration object for the Subnet. | Yes |

### subnet_config Object Schema

```hcl
{
  name                 = string
  resource_group_name  = string
  virtual_network_name = string
  address_prefixes     = list(string)
  service_endpoints    = optional(list(string), [])
  delegation           = optional(map(any), {})
  tags                 = optional(map(string), {})
}
```

### delegation Object Schema

```hcl
{
  service_name = string
  actions      = list(string)
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the Subnet. |
| name | The Name of the Subnet. |
| address_prefixes | The address prefixes of the Subnet. |

## Usage Example

```hcl
module "app_subnet" {
  source = "../../modules/swo_azurerm_subnet"

  subnet_config = {
    name                 = "snet-app-prod-weu-01"
    resource_group_name  = "rg-hub-prod-weu-01"
    virtual_network_name = "vnet-hub-prod-weu-01"
    address_prefixes     = ["10.222.217.0/24"]
    service_endpoints    = ["Microsoft.Storage"]
    delegation           = {}
    tags = {
      Environment = "Production"
      Owner       = "SAP Team"
    }
  }
}
```

## Notes
- The Subnet name must start with `snet-` as enforced by the validation rule.
- This module does not create Network Security Groups (NSGs). Use the `swo_azurerm_nsg` module for NSG creation.
