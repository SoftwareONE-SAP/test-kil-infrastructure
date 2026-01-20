output "id" {
  description = "The Resource ID of the VNet Peering."
  value       = azurerm_virtual_network_peering.this.id
}

output "name" {
  description = "The Name of the VNet Peering."
  value       = azurerm_virtual_network_peering.this.name
}