output "id" {
  description = "The Resource ID of the Virtual Network."
  value       = azurerm_virtual_network.this.id
}

output "name" {
  description = "The Name of the Virtual Network."
  value       = azurerm_virtual_network.this.name
}

output "address_space" {
  description = "The address space of the Virtual Network."
  value       = azurerm_virtual_network.this.address_space
}