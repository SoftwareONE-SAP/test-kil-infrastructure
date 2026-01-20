variable "route_table_config" {
  description = "Primary configuration object for the Route Table."
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    tags                = optional(map(string), {})
  })

  validation {
    condition     = can(regex("^rt-", var.route_table_config.name))
    error_message = "Route table name must start with 'rt-'."
  }
}

variable "routes" {
  description = "Map of routes to apply to the Route Table."
  type = map(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {}
}