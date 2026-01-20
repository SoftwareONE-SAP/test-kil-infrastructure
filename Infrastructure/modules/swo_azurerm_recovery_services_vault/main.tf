resource "azurerm_recovery_services_vault" "this" {
  name                = var.rsv_config.name
  location            = var.rsv_config.location
  resource_group_name = var.rsv_config.resource_group_name
  sku                 = var.rsv_config.sku
  soft_delete_enabled = var.rsv_config.soft_delete_enabled
  tags                = var.rsv_config.tags
}