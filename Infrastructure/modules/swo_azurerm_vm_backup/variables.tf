variable "backup_config" {
  description = "Primary configuration object for the VM Backup."
  type = object({
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
  })

  validation {
    condition     = can(regex("^backup-", var.backup_config.name))
    error_message = "Backup name must start with 'backup-'."
  }

  validation {
    condition     = contains(["Daily", "Weekly"], var.backup_config.backup_frequency)
    error_message = "Backup frequency must be either 'Daily' or 'Weekly'."
  }
}