# Proximity Placement Group for SAP workloads
resource "azurerm_proximity_placement_group" "sap" {
  name                = local.proximity_placement_group_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

# Network Interfaces
resource "azurerm_network_interface" "vms" {
  for_each = local.virtual_machines

  name                = "nic-${each.key}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  accelerated_networking_enabled = each.value.enable_accelerated_networking

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnets["${each.value.vnet_key}/${each.value.subnet_key}"].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

# Jump Host VM (Linux)
resource "azurerm_linux_virtual_machine" "jump" {
  name                = "vm-jump-${var.environment}-${local.region_code}-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = local.virtual_machines["vm-jump-${var.environment}-${local.region_code}-01"].vm_size
  zone                = local.virtual_machines["vm-jump-${var.environment}-${local.region_code}-01"].zone

  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  network_interface_ids = [
    azurerm_network_interface.vms["vm-jump-${var.environment}-${local.region_code}-01"].id
  ]

  os_disk {
    name                 = "osdisk-jump-${var.environment}-${local.region_code}-01"
    caching              = "ReadWrite"
    storage_account_type = local.virtual_machines["vm-jump-${var.environment}-${local.region_code}-01"].os_disk_storage_type
    disk_size_gb         = local.virtual_machines["vm-jump-${var.environment}-${local.region_code}-01"].os_disk_size_gb
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "9_2"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagnostics.primary_blob_endpoint
  }

  tags = merge(local.tags, {
    Role = "JumpHost"
  })
}

# SAP Application Server VM (Linux)
resource "azurerm_linux_virtual_machine" "app" {
  name                = "vm-s4app-${var.environment}-${local.region_code}-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = local.virtual_machines["vm-s4app-${var.environment}-${local.region_code}-01"].vm_size
  zone                = local.virtual_machines["vm-s4app-${var.environment}-${local.region_code}-01"].zone

  proximity_placement_group_id    = azurerm_proximity_placement_group.sap.id
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  network_interface_ids = [
    azurerm_network_interface.vms["vm-s4app-${var.environment}-${local.region_code}-01"].id
  ]

  os_disk {
    name                 = "osdisk-s4app-${var.environment}-${local.region_code}-01"
    caching              = "ReadWrite"
    storage_account_type = local.virtual_machines["vm-s4app-${var.environment}-${local.region_code}-01"].os_disk_storage_type
    disk_size_gb         = local.virtual_machines["vm-s4app-${var.environment}-${local.region_code}-01"].os_disk_size_gb
  }

  source_image_reference {
    publisher = "SUSE"
    offer     = "sles-sap-15-sp5"
    sku       = "gen2"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagnostics.primary_blob_endpoint
  }

  tags = merge(local.tags, {
    Role    = "SAP-Application"
    SAP_SID = var.sap_sid
  })
}

# SAP Application Server Data Disks
resource "azurerm_managed_disk" "app_disks" {
  for_each = {
    for disk in local.virtual_machines["vm-s4app-${var.environment}-${local.region_code}-01"].data_disks :
    disk.name => disk
  }

  name                 = each.value.name
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = each.value.storage_type
  create_option        = "Empty"
  disk_size_gb         = each.value.size_gb
  zone                 = local.virtual_machines["vm-s4app-${var.environment}-${local.region_code}-01"].zone

  tags = merge(local.tags, {
    AttachedTo = "vm-s4app-${var.environment}-${local.region_code}-01"
  })
}

resource "azurerm_virtual_machine_data_disk_attachment" "app_disks" {
  for_each = {
    for disk in local.virtual_machines["vm-s4app-${var.environment}-${local.region_code}-01"].data_disks :
    disk.name => disk
  }

  managed_disk_id    = azurerm_managed_disk.app_disks[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.app.id
  lun                = each.value.lun
  caching            = each.value.caching
}

# SAP HANA Database VM (Linux)
resource "azurerm_linux_virtual_machine" "hana" {
  name                = "vm-hana-${var.environment}-${local.region_code}-01"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = local.virtual_machines["vm-hana-${var.environment}-${local.region_code}-01"].vm_size
  zone                = local.virtual_machines["vm-hana-${var.environment}-${local.region_code}-01"].zone

  proximity_placement_group_id    = azurerm_proximity_placement_group.sap.id
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  network_interface_ids = [
    azurerm_network_interface.vms["vm-hana-${var.environment}-${local.region_code}-01"].id
  ]

  os_disk {
    name                 = "osdisk-hana-${var.environment}-${local.region_code}-01"
    caching              = "ReadWrite"
    storage_account_type = local.virtual_machines["vm-hana-${var.environment}-${local.region_code}-01"].os_disk_storage_type
    disk_size_gb         = local.virtual_machines["vm-hana-${var.environment}-${local.region_code}-01"].os_disk_size_gb
  }

  source_image_reference {
    publisher = "SUSE"
    offer     = "sles-sap-15-sp5"
    sku       = "gen2"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diagnostics.primary_blob_endpoint
  }

  tags = merge(local.tags, {
    Role    = "SAP-HANA-Database"
    SAP_SID = var.sap_sid
  })
}

# SAP HANA Database Data Disks
resource "azurerm_managed_disk" "hana_disks" {
  for_each = {
    for disk in local.virtual_machines["vm-hana-${var.environment}-${local.region_code}-01"].data_disks :
    disk.name => disk
  }

  name                 = each.value.name
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = each.value.storage_type
  create_option        = "Empty"
  disk_size_gb         = each.value.size_gb
  zone                 = local.virtual_machines["vm-hana-${var.environment}-${local.region_code}-01"].zone

  # Premium SSD v2 specific settings
  disk_iops_read_write = try(each.value.disk_iops_read_write, null)
  disk_mbps_read_write = try(each.value.disk_mbps_read_write, null)

  tags = merge(local.tags, {
    AttachedTo = "vm-hana-${var.environment}-${local.region_code}-01"
  })
}

resource "azurerm_virtual_machine_data_disk_attachment" "hana_disks" {
  for_each = {
    for disk in local.virtual_machines["vm-hana-${var.environment}-${local.region_code}-01"].data_disks :
    disk.name => disk
  }

  managed_disk_id    = azurerm_managed_disk.hana_disks[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.hana.id
  lun                = each.value.lun
  caching            = try(each.value.caching, "None")
}
