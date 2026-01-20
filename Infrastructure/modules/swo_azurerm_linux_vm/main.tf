resource "azurerm_network_interface" "this" {
  name                = "${var.vm_config.name}-nic"
  location            = var.vm_config.location
  resource_group_name = var.vm_config.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.vm_config.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.vm_config.name
  location            = var.vm_config.location
  resource_group_name = var.vm_config.resource_group_name
  size                = var.vm_config.size
  admin_username      = var.vm_config.admin_username
  network_interface_ids = [azurerm_network_interface.this.id]
  proximity_placement_group_id = var.vm_config.proximity_placement_group_id

  os_disk {
    caching              = var.os_disk_config.caching
    storage_account_type = var.os_disk_config.storage_account_type
    disk_size_gb         = var.os_disk_config.disk_size_gb
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_config.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  tags = var.vm_config.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each           = var.data_disks
  managed_disk_id    = each.value.disk_id
  virtual_machine_id = azurerm_linux_virtual_machine.this.id
  lun                = each.value.lun
  caching            = each.value.caching
}