variable "disk_config" {
  description = "Primary configuration object for the Managed Disk."
  type = object({
    name                 = string
    location             = string
    resource_group_name  = string
    storage_account_type = string
    create_option        = string
    disk_size_gb         = number
    zones                = optional(list(string))
    tags                 = optional(map(string), {})
  })

  validation {
    condition     = length(var.disk_config.name) > 0
    error_message = "Disk name must not be empty."
  }

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "PremiumV2_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.disk_config.storage_account_type)
    error_message = "Storage account type must be one of: Standard_LRS, StandardSSD_LRS, Premium_LRS, PremiumV2_LRS, StandardSSD_ZRS, Premium_ZRS."
  }

  validation {
    condition     = contains(["Empty", "FromImage", "Import"], var.disk_config.create_option)
    error_message = "Create option must be one of: Empty, FromImage, Import."
  }

  validation {
    condition     = var.disk_config.disk_size_gb > 0
    error_message = "Disk size must be greater than 0 GB."
  }
}