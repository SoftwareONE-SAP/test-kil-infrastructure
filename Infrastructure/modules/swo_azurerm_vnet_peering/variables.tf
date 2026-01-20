variable "peering_config" {
  description = "Primary configuration object for the VNet Peering."
  type = object({
    name                          = string
    resource_group_name           = string
    virtual_network_name          = string
    remote_virtual_network_id     = string
    allow_virtual_network_access  = optional(bool, true)
    allow_forwarded_traffic       = optional(bool, false)
    allow_gateway_transit         = optional(bool, false)
    use_remote_gateways           = optional(bool, false)
  })

  validation {
    condition     = can(regex("^peer-", var.peering_config.name))
    error_message = "Peering name must start with 'peer-'."
  }
}