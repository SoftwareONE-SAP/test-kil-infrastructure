# Output Resource IDs
output "resource_group_id" {
  description = "The Resource ID of the Resource Group."
  value       = azurerm_resource_group.this.id
}

output "hub_vnet_id" {
  description = "The Resource ID of the Hub VNet."
  value       = module.hub_vnet.id
}

output "spoke_vnet_id" {
  description = "The Resource ID of the Spoke VNet."
  value       = module.spoke_vnet.id
}

output "storage_account_id" {
  description = "The Resource ID of the Storage Account."
  value       = module.sap_diagnostics_storage.id
}

output "vm_jumphost_id" {
  description = "The Resource ID of the Jump Host VM."
  value       = module.vm-jumphost.id
}

output "vm_s4app_01_id" {
  description = "The Resource ID of the SAP App VM."
  value       = module.vm-s4app-01.id
}

output "vm_hana_01_id" {
  description = "The Resource ID of the SAP HANA VM."
  value       = module.vm-hana-01.id
}

output "rsv_id" {
  description = "The Resource ID of the Recovery Services Vault."
  value       = module.sap_rsv.id
}