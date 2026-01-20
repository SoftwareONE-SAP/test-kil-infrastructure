# Create Recovery Services Vault
module "sap_rsv" {
  source = "../../modules/swo_azurerm_recovery_services_vault"

  rsv_config = {
    name                = local.backup_config.rsv_name
    location            = local.location
    resource_group_name = azurerm_resource_group.this.name
    sku                 = local.backup_config.rsv_sku
    soft_delete_enabled = true
    tags                = local.tags
  }
}

# Create VM Backups
module "vm_backups" {
  for_each = {
    jumphost = {
      name             = "backup-jumphost"
      vm_id            = module.vm-jumphost.id
      backup_frequency = "Daily"
      backup_time      = "23:00"
      retention_daily  = 30
      retention_weekly = 12
      retention_monthly = 12
      retention_yearly = 1
    }
    s4app = {
      name             = "backup-s4app-01"
      vm_id            = module.vm-s4app-01.id
      backup_frequency = "Daily"
      backup_time      = "23:00"
      retention_daily  = 30
      retention_weekly = 12
      retention_monthly = 12
      retention_yearly = 1
    }
  }
  source = "../../modules/swo_azurerm_vm_backup"

  backup_config = {
    name                   = each.value.name
    resource_group_name    = azurerm_resource_group.this.name
    recovery_vault_name    = module.sap_rsv.name
    vm_id                  = each.value.vm_id
    backup_policy_id       = ""
    backup_frequency       = each.value.backup_frequency
    backup_time            = each.value.backup_time
    retention_daily_count  = each.value.retention_daily
    retention_weekly_count = each.value.retention_weekly
    retention_monthly_count = each.value.retention_monthly
    retention_yearly_count = each.value.retention_yearly
  }

  depends_on = [module.sap_rsv]
}

# Create SAP HANA Backup
module "sap_hana_backup" {
  source = "../../modules/swo_azurerm_sap_hana_backup"

  hana_backup_config = {
    name                   = "backup-hana-01"
    resource_group_name    = azurerm_resource_group.this.name
    recovery_vault_name    = module.sap_rsv.name
    hana_server_name       = module.vm-hana-01.id
    hana_database_name     = "HDB"
    backup_frequency       = "Daily"
    backup_time            = "23:00"
    retention_daily_count  = 30
    retention_weekly_count = 12
    retention_monthly_count = 12
    retention_yearly_count = 1
  }

  depends_on = [module.sap_rsv]
}