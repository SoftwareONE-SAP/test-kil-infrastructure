variable "nsg_config" {
  description = "Primary configuration object for the Network Security Group."
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    tags                = optional(map(string), {})
  })

  validation {
    condition     = can(regex("^nsg-", var.nsg_config.name))
    error_message = "NSG name must start with 'nsg-'."
  }
}

variable "security_rules" {
  description = "Map of security rules to apply to the NSG."
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string)
    source_port_ranges         = optional(list(string))
    destination_port_range     = optional(string)
    destination_port_ranges    = optional(list(string))
    source_address_prefix      = optional(string)
    source_address_prefixes    = optional(list(string))
    destination_address_prefix = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
  default = {}

  validation {
    condition     = alltrue([for r in var.security_rules : contains(["Inbound", "Outbound"], r.direction)])
    error_message = "Security rule direction must be Inbound or Outbound."
  }

  validation {
    condition     = alltrue([for r in var.security_rules : contains(["Allow", "Deny"], r.access)])
    error_message = "Security rule access must be Allow or Deny."
  }
}