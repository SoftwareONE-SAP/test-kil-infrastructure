# swo_azurerm_proximity_placement_group

## Purpose
This module creates an Azure Proximity Placement Group (PPG) using an object-based input pattern. It is designed for reuse across multiple environments and adheres to the Unified Master Terraform Coding Standards.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| ppg_config | object | Primary configuration object for the Proximity Placement Group. | Yes |

### ppg_config Object Schema

```hcl
{
  name                = string
  location            = string
  resource_group_name = string
  tags                = optional(map(string), {})
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the Proximity Placement Group. |
| name | The Name of the Proximity Placement Group. |

## Usage Example

```hcl
module "sap_ppg" {
  source = "../../modules/swo_azurerm_proximity_placement_group"

  ppg_config = {
    name                = "ppg-sap-prod-weu-01"
    location            = "westeurope"
    resource_group_name = "rg-sap-prod-weu-01"
    tags = {
      Environment = "Production"
      Owner       = "SAP Team"
    }
  }
}
```

## Notes
- The PPG name must start with `ppg-` as enforced by the validation rule.
- This module does not create VMs or associate them with the PPG. Use the `proximity_placement_group_id` attribute in your VM module to associate VMs with the PPG.
