# swo_azurerm_sap_hana_backup

## Purpose
This module creates an Azure Backup policy for SAP HANA and associates it with a HANA server using an object-based input pattern. It is designed for reuse across multiple environments and adheres to the Unified Master Terraform Coding Standards.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| hana_backup_config | object | Primary configuration object for the SAP HANA Backup. | Yes |

### hana_backup_config Object Schema

```hcl
{
  name                = string
  resource_group_name = string
  recovery_vault_name = string
  hana_server_name    = string
  hana_database_name  = string
  backup_frequency    = string
  backup_time         = string
  retention_daily_count = number
  retention_weekly_count = number
  retention_monthly_count = number
  retention_yearly_count = number
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the SAP HANA Backup. |
| name | The Name of the SAP HANA Backup. |
| backup_policy_id | The Resource ID of the Backup Policy. |

## Usage Example

```hcl
module "sap_hana_backup" {
  source = "../../modules/swo_azurerm_sap_hana_backup"

  hana_backup_config = {
    name                = "backup-hana-01"
    resource_group_name = "rg-sap-prod-weu-01"
    recovery_vault_name = "rsv-sap-prod-weu-01"
    hana_server_name    = module.sap_hana_vm.id
    hana_database_name  = "HDB"
    backup_frequency    = "Daily"
    backup_time         = "23:00"
    retention_daily_count = 30
    retention_weekly_count = 12
    retention_monthly_count = 12
    retention_yearly_count = 1
  }
}
```

## Notes
- The HANA Backup name must start with `backup-hana-` as enforced by the validation rule.
- This module creates both a backup policy and associates the HANA server with that policy.
