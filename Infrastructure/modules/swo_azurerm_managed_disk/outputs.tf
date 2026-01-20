output "id" {
  description = "The Resource ID of the Managed Disk."
  value       = azurerm_managed_disk.this.id
}

output "name" {
  description = "The Name of the Managed Disk."
  value       = azurerm_managed_disk.this.name
}