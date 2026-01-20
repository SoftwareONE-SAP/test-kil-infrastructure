variable "vm_config" {
  description = "Primary configuration object for the Linux Virtual Machine."
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    size                = string
    admin_username      = string
    subnet_id           = string
    proximity_placement_group_id = optional(string)
    enable_accelerated_networking = optional(bool, false)
    tags                = optional(map(string), {})
  })
  sensitive = true

  validation {
    condition     = can(regex("^vm-", var.vm_config.name))
    error_message = "VM name must start with 'vm-'."
  }

  validation {
    condition     = length(var.vm_config.admin_username) >= 3
    error_message = "admin_username must be at least 3 characters long."
  }
}

variable "os_disk_config" {
  description = "Configuration object for the OS disk."
  type = object({
    caching              = string
    storage_account_type = string
    disk_size_gb         = number
  })
  default = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }
}

variable "data_disks" {
  description = "Map of data disks to attach to the VM."
  type = map(object({
    name                 = string
    disk_id              = string
    caching              = string
    lun                  = number
    storage_account_type = string
    disk_size_gb         = number
  }))
  default = {}
}

variable "source_image_reference" {
  description = "Source image reference for the VM."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}