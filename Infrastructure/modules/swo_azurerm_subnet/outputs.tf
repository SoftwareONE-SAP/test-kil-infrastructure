output "id" {
  description = "The Resource ID of the Subnet."
  value       = azurerm_subnet.this.id
}

output "name" {
  description = "The Name of the Subnet."
  value       = azurerm_subnet.this.name
}

output "address_prefixes" {
  description = "The address prefixes of the Subnet."
  value       = azurerm_subnet.this.address_prefixes
}