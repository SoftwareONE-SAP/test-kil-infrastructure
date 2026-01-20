# swo_azurerm_nsg

## Purpose
This module creates an Azure Network Security Group (NSG) and applies a set of security rules using an object-based input pattern. It is designed for reuse across multiple environments and adheres to the Unified Master Terraform Coding Standards.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| nsg_config | object | Primary configuration object for the Network Security Group. | Yes |
| security_rules | map(object) | Map of security rules to apply to the NSG. | No |

### nsg_config Object Schema

```hcl
{
  name                = string
  location            = string
  resource_group_name = string
  tags                = optional(map(string), {})
}
```

### security_rules Map Schema

```hcl
{
  name                       = string
  priority                   = number
  direction                  = string
  access                     = string
  protocol                   = string
  source_port_range          = optional(string)
  source_port_ranges         = optional(list(string))
  destination_port_range     = optional(string)
  destination_port_ranges    = optional(list(string))
  source_address_prefix      = optional(string)
  source_address_prefixes    = optional(list(string))
  destination_address_prefix = optional(string)
  destination_address_prefixes = optional(list(string))
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the Network Security Group. |
| name | The Name of the Network Security Group. |
| security_rule_ids | Map of security rule IDs by rule name. |

## Usage Example

```hcl
module "app_nsg" {
  source = "../../modules/swo_azurerm_nsg"

  nsg_config = {
    name                = "nsg-app-prod-weu-01"
    location            = "westeurope"
    resource_group_name = "rg-hub-prod-weu-01"
    tags = {
      Environment = "Production"
      Owner       = "SAP Team"
    }
  }

  security_rules = {
    "allow-http" = {
      name                       = "allow-http"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
```

## Notes
- The NSG name must start with `nsg-` as enforced by the validation rule.
- This module does not associate the NSG with subnets. Use the `azurerm_subnet_network_security_group_association` resource in your environment code to associate NSGs with subnets.
