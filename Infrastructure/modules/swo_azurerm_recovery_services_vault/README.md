# swo_azurerm_recovery_services_vault

## Purpose
This module creates an Azure Recovery Services Vault using an object-based input pattern. It is designed for reuse across multiple environments and adheres to the Unified Master Terraform Coding Standards.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| rsv_config | object | Primary configuration object for the Recovery Services Vault. | Yes |

### rsv_config Object Schema

```hcl
{
  name                = string
  location            = string
  resource_group_name = string
  sku                 = string
  soft_delete_enabled = optional(bool, true)
  tags                = optional(map(string), {})
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the Recovery Services Vault. |
| name | The Name of the Recovery Services Vault. |

## Usage Example

```hcl
module "sap_rsv" {
  source = "../../modules/swo_azurerm_recovery_services_vault"

  rsv_config = {
    name                = "rsv-sap-prod-weu-01"
    location            = "westeurope"
    resource_group_name = "rg-sap-prod-weu-01"
    sku                 = "Standard"
    soft_delete_enabled = true
    tags = {
      Environment = "Production"
      Owner       = "SAP Team"
    }
  }
}
```

## Notes
- The RSV name must start with `rsv-` as enforced by the validation rule.
- This module does not create backup policies or associate VMs with the RSV. Use the appropriate modules for those tasks.
