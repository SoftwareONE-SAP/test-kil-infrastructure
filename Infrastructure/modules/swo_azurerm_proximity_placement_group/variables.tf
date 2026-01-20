variable "ppg_config" {
  description = "Primary configuration object for the Proximity Placement Group."
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    tags                = optional(map(string), {})
  })

  validation {
    condition     = can(regex("^ppg-", var.ppg_config.name))
    error_message = "PPG name must start with 'ppg-'."
  }
}