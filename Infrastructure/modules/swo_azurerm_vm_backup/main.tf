resource "azurerm_backup_protected_vm" "this" {
  resource_group_name = var.backup_config.resource_group_name
  recovery_vault_name = var.backup_config.recovery_vault_name
  source_vm_id        = var.backup_config.vm_id
  backup_policy_id    = var.backup_config.backup_policy_id
}

resource "azurerm_backup_policy_vm" "this" {
  name                = var.backup_config.name
  resource_group_name = var.backup_config.resource_group_name
  recovery_vault_name = var.backup_config.recovery_vault_name

  backup {
    frequency = var.backup_config.backup_frequency
    time      = var.backup_config.backup_time
  }

  retention_daily {
    count = var.backup_config.retention_daily_count
  }

  retention_weekly {
    count    = var.backup_config.retention_weekly_count
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count    = var.backup_config.retention_monthly_count
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }

  retention_yearly {
    count    = var.backup_config.retention_yearly_count
    weekdays = ["Sunday"]
    weeks    = ["First"]
    months   = ["January"]
  }
}