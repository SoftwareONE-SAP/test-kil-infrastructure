# Create Storage Account
module "sap_diagnostics_storage" {
  source = "../../modules/swo_azurerm_storage_account"

  storage_config = {
    name                     = local.storage_account.name
    location                 = local.location
    resource_group_name      = azurerm_resource_group.this.name
    account_tier             = local.storage_account.account_tier
    account_replication_type = local.storage_account.account_replication_type
    tags                     = local.tags
  }
}

# Create Managed Disks
module "disks" {
  for_each = local.disks
  source   = "../../modules/swo_azurerm_managed_disk"

  disk_config = {
    name                 = each.value.name
    location             = local.location
    resource_group_name  = azurerm_resource_group.this.name
    storage_account_type = each.value.storage_account_type
    create_option        = "Empty"
    disk_size_gb         = each.value.disk_size_gb
    tags                 = local.tags
  }
}