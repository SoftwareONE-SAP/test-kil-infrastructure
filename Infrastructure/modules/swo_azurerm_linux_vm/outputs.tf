output "id" {
  description = "The Resource ID of the Virtual Machine."
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "The Name of the Virtual Machine."
  value       = azurerm_linux_virtual_machine.this.name
}

output "identity_principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity."
  value       = try(azurerm_linux_virtual_machine.this.identity[0].principal_id, null)
}

output "network_interface_id" {
  description = "The Resource ID of the Network Interface."
  value       = azurerm_network_interface.this.id
}