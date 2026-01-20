resource "azurerm_backup_policy_vm" "this" {
  name                = var.hana_backup_config.name
  resource_group_name = var.hana_backup_config.resource_group_name
  recovery_vault_name = var.hana_backup_config.recovery_vault_name

  backup {
    frequency = var.hana_backup_config.backup_frequency
    time      = var.hana_backup_config.backup_time
  }

  retention_daily {
    count = var.hana_backup_config.retention_daily_count
  }

  retention_weekly {
    count    = var.hana_backup_config.retention_weekly_count
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count    = var.hana_backup_config.retention_monthly_count
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }

  retention_yearly {
    count    = var.hana_backup_config.retention_yearly_count
    weekdays = ["Sunday"]
    weeks    = ["First"]
    months   = ["January"]
  }
}

resource "azurerm_backup_protected_vm" "this" {
  resource_group_name = var.hana_backup_config.resource_group_name
  recovery_vault_name = var.hana_backup_config.recovery_vault_name
  source_vm_id        = var.hana_backup_config.hana_server_name
  backup_policy_id    = azurerm_backup_policy_vm.this.id
}