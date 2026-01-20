output "id" {
  description = "The Resource ID of the Route Table."
  value       = azurerm_route_table.this.id
}

output "name" {
  description = "The Name of the Route Table."
  value       = azurerm_route_table.this.name
}

output "route_ids" {
  description = "Map of route IDs by route name."
  value       = { for k, v in azurerm_route.this : k => v.id }
}