variable "storage_config" {
  description = "Primary configuration object for the Storage Account."
  type = object({
    name                     = string
    location                 = string
    resource_group_name      = string
    account_tier             = string
    account_replication_type = string
    tags                     = optional(map(string), {})
  })

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_config.name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_config.account_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_config.account_replication_type)
    error_message = "Account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}