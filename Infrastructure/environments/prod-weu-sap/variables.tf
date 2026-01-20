variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "westeurope"

  validation {
    condition     = can(regex("^[a-z]+$", var.location))
    error_message = "Location must be a valid Azure region name in lowercase without spaces."
  }
}

variable "environment" {
  description = "Environment name (e.g., prod, nonprod)."
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["prod", "nonprod", "dev", "test"], var.environment)
    error_message = "Environment must be one of: prod, nonprod, dev, test."
  }
}

variable "sap_sid" {
  description = "SAP System ID (3 characters)."
  type        = string
  default     = "S4H"

  validation {
    condition     = can(regex("^[A-Z0-9]{3}$", var.sap_sid))
    error_message = "SAP SID must be exactly 3 uppercase alphanumeric characters."
  }
}

variable "admin_username" {
  description = "Administrator username for all VMs."
  type        = string
  default     = "azureadmin"
  sensitive   = true
}

variable "admin_password" {
  description = "Administrator password for all VMs. Should be retrieved from Key Vault in production."
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for Linux VM authentication."
  type        = string
  sensitive   = true
}

variable "cost_centre" {
  description = "Cost centre code for billing and tagging."
  type        = string
  default     = "CC-SAP-001"
}

variable "enable_backup" {
  description = "Enable Azure Backup for VMs and HANA."
  type        = bool
  default     = true
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking on SAP VMs (required for production)."
  type        = bool
  default     = true
}
