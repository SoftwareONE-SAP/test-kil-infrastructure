variable "vnet_config" {
  description = "Primary configuration object for the Virtual Network."
  type = object({
    name          = string
    location      = string
    resource_group_name = string
    address_space = list(string)
    tags          = optional(map(string), {})
  })

  validation {
    condition     = can(regex("^vnet-", var.vnet_config.name))
    error_message = "VNet name must start with 'vnet-'."
  }
}