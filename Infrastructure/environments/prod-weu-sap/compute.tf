# Create Proximity Placement Group
module "sap_ppg" {
  source = "../../modules/swo_azurerm_proximity_placement_group"

  ppg_config = {
    name                = "ppg-sap-prod-weu-01"
    location            = local.location
    resource_group_name = azurerm_resource_group.this.name
    tags                = local.tags
  }
}

# Create VMs
module "vm-jumphost" {
  source = "../../modules/swo_azurerm_linux_vm"

  vm_config = {
    name                = "vm-jumphost"
    location            = local.location
    resource_group_name = azurerm_resource_group.this.name
    size                = local.virtual_machines["vm-jumphost"].size
    admin_username      = var.admin_username
    subnet_id           = module.hub_subnets["snet-jump-prod-weu-01"].id
    enable_accelerated_networking = local.virtual_machines["vm-jumphost"].enable_accelerated_networking
    tags                = local.tags
  }

  os_disk_config = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

module "vm-s4app-01" {
  source = "../../modules/swo_azurerm_linux_vm"

  vm_config = {
    name                = "vm-s4app-01"
    location            = local.location
    resource_group_name = azurerm_resource_group.this.name
    size                = local.virtual_machines["vm-s4app-01"].size
    admin_username      = var.admin_username
    subnet_id           = module.spoke_subnets["snet-app-prod-weu-01"].id
    proximity_placement_group_id = module.sap_ppg.id
    enable_accelerated_networking = local.virtual_machines["vm-s4app-01"].enable_accelerated_networking
    tags                = local.tags
  }

  os_disk_config = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  data_disks = {
    "data-disk-1" = {
      name                 = "disk-s4app-data-01"
      disk_id              = module.disks["disk-s4app-data"].id
      caching              = "ReadWrite"
      lun                  = 10
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 128
    }
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

module "vm-hana-01" {
  source = "../../modules/swo_azurerm_linux_vm"

  vm_config = {
    name                = "vm-hana-01"
    location            = local.location
    resource_group_name = azurerm_resource_group.this.name
    size                = local.virtual_machines["vm-hana-01"].size
    admin_username      = var.admin_username
    subnet_id           = module.spoke_subnets["snet-db-prod-weu-01"].id
    proximity_placement_group_id = module.sap_ppg.id
    enable_accelerated_networking = local.virtual_machines["vm-hana-01"].enable_accelerated_networking
    tags                = local.tags
  }

  os_disk_config = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  data_disks = {
    "data-disk-1" = {
      name                 = "disk-hana-data-01"
      disk_id              = module.disks["disk-hana-data"].id
      caching              = "ReadWrite"
      lun                  = 10
      storage_account_type = "PremiumV2_LRS"
      disk_size_gb         = 640
    }
    "log-disk-1" = {
      name                 = "disk-hana-log-01"
      disk_id              = module.disks["disk-hana-log"].id
      caching              = "ReadWrite"
      lun                  = 11
      storage_account_type = "PremiumV2_LRS"
      disk_size_gb         = 256
    }
    "shared-disk-1" = {
      name                 = "disk-hana-shared-01"
      disk_id              = module.disks["disk-hana-shared"].id
      caching              = "ReadWrite"
      lun                  = 12
      storage_account_type = "PremiumV2_LRS"
      disk_size_gb         = 512
    }
    "backup-disk-1" = {
      name                 = "disk-hana-backup-01"
      disk_id              = module.disks["disk-hana-backup"].id
      caching              = "ReadWrite"
      lun                  = 13
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 2048
    }
  }

  source_image_reference = {
    publisher = "SUSE"
    offer     = "sles-sap-15-sp3"
    sku       = "gen2"
    version   = "latest"
  }
}