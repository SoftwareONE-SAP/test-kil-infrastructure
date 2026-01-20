# swo_azurerm_vm_backup

## Purpose
This module creates an Azure VM Backup policy and associates it with a VM using an object-based input pattern. It is designed for reuse across multiple environments and adheres to the Unified Master Terraform Coding Standards.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| backup_config | object | Primary configuration object for the VM Backup. | Yes |

### backup_config Object Schema

```hcl
{
  name                         = string
  resource_group_name          = string
  recovery_vault_name          = string
  vm_id                        = string
  backup_policy_id            = string
  backup_frequency             = string
  backup_time                  = string
  retention_daily_count        = number
  retention_weekly_count       = number
  retention_monthly_count      = number
  retention_yearly_count       = number
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the VM Backup. |
| name | The Name of the VM Backup. |
| backup_policy_id | The Resource ID of the Backup Policy. |

## Usage Example

```hcl
module "sap_app_backup" {
  source = "../../modules/swo_azurerm_vm_backup"

  backup_config = {
    name                         = "backup-s4app-01"
    resource_group_name          = "rg-sap-prod-weu-01"
    recovery_vault_name          = "rsv-sap-prod-weu-01"
    vm_id                        = module.sap_app_vm.id
    backup_policy_id            = ""
    backup_frequency             = "Daily"
    backup_time                  = "23:00"
    retention_daily_count        = 30
    retention_weekly_count       = 12
    retention_monthly_count      = 12
    retention_yearly_count       = 1
  }
}
```

## Notes
- The Backup name must start with `backup-` as enforced by the validation rule.
- This module creates both a backup policy and associates the VM with that policy.
