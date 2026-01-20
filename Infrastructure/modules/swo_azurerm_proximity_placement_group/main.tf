resource "azurerm_proximity_placement_group" "this" {
  name                = var.ppg_config.name
  location            = var.ppg_config.location
  resource_group_name = var.ppg_config.resource_group_name
  tags                = var.ppg_config.tags
}