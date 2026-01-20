output "id" {
  description = "The Resource ID of the VM Backup."
  value       = azurerm_backup_protected_vm.this.id
}

output "name" {
  description = "The Name of the VM Backup."
  value       = azurerm_backup_protected_vm.this.name
}

output "backup_policy_id" {
  description = "The Resource ID of the Backup Policy."
  value       = azurerm_backup_policy_vm.this.id
}