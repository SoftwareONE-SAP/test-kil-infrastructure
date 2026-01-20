variable "hana_backup_config" {
  description = "Primary configuration object for the SAP HANA Backup."
  type = object({
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
  })

  validation {
    condition     = can(regex("^backup-hana-", var.hana_backup_config.name))
    error_message = "HANA Backup name must start with 'backup-hana-'."
  }

  validation {
    condition     = contains(["Daily", "Weekly"], var.hana_backup_config.backup_frequency)
    error_message = "Backup frequency must be either 'Daily' or 'Weekly'."
  }
}