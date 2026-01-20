output "id" {
  description = "The Resource ID of the Recovery Services Vault."
  value       = azurerm_recovery_services_vault.this.id
}

output "name" {
  description = "The Name of the Recovery Services Vault."
  value       = azurerm_recovery_services_vault.this.name
}