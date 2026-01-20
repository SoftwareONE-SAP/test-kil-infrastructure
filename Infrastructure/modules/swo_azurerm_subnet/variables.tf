variable "subnet_config" {
  description = "Primary configuration object for the Subnet."
  type = object({
    name                 = string
    resource_group_name  = string
    virtual_network_name = string
    address_prefixes     = list(string)
    service_endpoints    = optional(list(string), [])
    delegation           = optional(map(any), {})
    tags                 = optional(map(string), {})
  })

  validation {
    condition     = can(regex("^snet-", var.subnet_config.name))
    error_message = "Subnet name must start with 'snet-'."
  }
}