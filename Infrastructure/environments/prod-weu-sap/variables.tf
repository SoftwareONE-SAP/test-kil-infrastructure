variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default = {
    Environment = "Production"
    Owner       = "SAP Team"
  }
}

variable "admin_username" {
  description = "Admin username for the VMs."
  type        = string
  default     = "azureadmin"
}