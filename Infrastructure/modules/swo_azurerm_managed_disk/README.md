# swo_azurerm_managed_disk

## Purpose
This module creates an Azure Managed Disk using an object-based input pattern. It is designed for reuse across multiple environments and adheres to the Unified Master Terraform Coding Standards.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| disk_config | object | Primary configuration object for the Managed Disk. | Yes |

### disk_config Object Schema

```hcl
{
  name                 = string
  location             = string
  resource_group_name  = string
  storage_account_type = string
  create_option        = string
  disk_size_gb         = number
  zones                = optional(list(string))
  tags                 = optional(map(string), {})
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the Managed Disk. |
| name | The Name of the Managed Disk. |

## Usage Example

```hcl
module "hana_data_disk" {
  source = "../../modules/swo_azurerm_managed_disk"

  disk_config = {
    name                 = "disk-hana-data-01"
    location             = "westeurope"
    resource_group_name  = "rg-sap-prod-weu-01"
    storage_account_type = "PremiumV2_LRS"
    create_option        = "Empty"
    disk_size_gb         = 640
    tags = {
      Environment = "Production"
      Owner       = "SAP Team"
    }
  }
}
```

## Notes
- The Storage Account type must be one of: Standard_LRS, StandardSSD_LRS, Premium_LRS, PremiumV2_LRS, StandardSSD_ZRS, Premium_ZRS.
- The Create option must be one of: Empty, FromImage, Import.
