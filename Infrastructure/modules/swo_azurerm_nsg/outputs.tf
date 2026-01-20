output "id" {
  description = "The Resource ID of the Network Security Group."
  value       = azurerm_network_security_group.this.id
}

output "name" {
  description = "The Name of the Network Security Group."
  value       = azurerm_network_security_group.this.name
}

output "security_rule_ids" {
  description = "Map of security rule IDs by rule name."
  value       = { for k, v in azurerm_network_security_rule.this : k => v.id }
}