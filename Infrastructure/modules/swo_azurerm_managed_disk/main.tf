resource "azurerm_managed_disk" "this" {
  name                 = var.disk_config.name
  location             = var.disk_config.location
  resource_group_name  = var.disk_config.resource_group_name
  storage_account_type = var.disk_config.storage_account_type
  create_option        = var.disk_config.create_option
  disk_size_gb         = var.disk_config.disk_size_gb
  tags                 = var.disk_config.tags
}