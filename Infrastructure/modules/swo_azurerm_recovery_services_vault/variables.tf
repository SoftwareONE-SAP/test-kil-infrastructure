variable "rsv_config" {
  description = "Primary configuration object for the Recovery Services Vault."
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    sku                 = string
    soft_delete_enabled = optional(bool, true)
    tags                = optional(map(string), {})
  })

  validation {
    condition     = can(regex("^rsv-", var.rsv_config.name))
    error_message = "RSV name must start with 'rsv-'."
  }

  validation {
    condition     = contains(["Standard", "RS0"], var.rsv_config.sku)
    error_message = "SKU must be either 'Standard' or 'RS0'."
  }

  validation {
    condition     = length(var.rsv_config.location) > 0
    error_message = "Location must be a non-empty string."
  }
}