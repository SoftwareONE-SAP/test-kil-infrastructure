resource "azurerm_storage_account" "this" {
  name                     = var.storage_config.name
  location                 = var.storage_config.location
  resource_group_name      = var.storage_config.resource_group_name
  account_tier             = var.storage_config.account_tier
  account_replication_type = var.storage_config.account_replication_type
  tags                     = var.storage_config.tags
}