# swo_azurerm_storage_account

## Purpose
This module creates an Azure Storage Account using an object-based input pattern. It is designed for reuse across multiple environments and adheres to the Unified Master Terraform Coding Standards.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| storage_config | object | Primary configuration object for the Storage Account. | Yes |

### storage_config Object Schema

```hcl
{
  name                     = string
  location                 = string
  resource_group_name      = string
  account_tier             = string
  account_replication_type = string
  tags                     = optional(map(string), {})
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the Storage Account. |
| name | The Name of the Storage Account. |
| primary_blob_endpoint | The primary blob endpoint of the Storage Account. |

## Usage Example

```hcl
module "sap_diagnostics_storage" {
  source = "../../modules/swo_azurerm_storage_account"

  storage_config = {
    name                     = "stdiagweu01"
    location                 = "westeurope"
    resource_group_name      = "rg-sap-prod-weu-01"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    tags = {
      Environment = "Production"
      Owner       = "SAP Team"
    }
  }
}
```

## Notes
- The Storage Account name must be 3-24 lowercase alphanumeric characters as enforced by the validation rule.
- This module does not create containers or blobs. Use additional resources in your environment code for those.
