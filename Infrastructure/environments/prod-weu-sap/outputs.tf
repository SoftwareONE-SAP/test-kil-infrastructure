# Resource Group Outputs
output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "The ID of the resource group."
  value       = azurerm_resource_group.main.id
}

# Network Outputs
output "hub_vnet_id" {
  description = "The ID of the Hub VNet."
  value       = azurerm_virtual_network.vnets[local.hub_vnet_name].id
}

output "spoke_vnet_id" {
  description = "The ID of the Spoke VNet."
  value       = azurerm_virtual_network.vnets[local.spoke_vnet_name].id
}

output "subnet_ids" {
  description = "Map of all subnet IDs."
  value = {
    for key, subnet in azurerm_subnet.subnets :
    key => subnet.id
  }
}

output "nsg_ids" {
  description = "Map of Network Security Group IDs."
  value = {
    jump = azurerm_network_security_group.jump.id
    app  = azurerm_network_security_group.app.id
    db   = azurerm_network_security_group.db.id
  }
}

# Compute Outputs
output "jump_host_vm_id" {
  description = "The ID of the Jump Host VM."
  value       = azurerm_linux_virtual_machine.jump.id
}

output "jump_host_private_ip" {
  description = "The private IP address of the Jump Host."
  value       = azurerm_network_interface.vms["vm-jump-${var.environment}-${local.region_code}-01"].private_ip_address
}

output "sap_app_vm_id" {
  description = "The ID of the SAP Application Server VM."
  value       = azurerm_linux_virtual_machine.app.id
}

output "sap_app_private_ip" {
  description = "The private IP address of the SAP Application Server."
  value       = azurerm_network_interface.vms["vm-s4app-${var.environment}-${local.region_code}-01"].private_ip_address
}

output "sap_hana_vm_id" {
  description = "The ID of the SAP HANA Database VM."
  value       = azurerm_linux_virtual_machine.hana.id
}

output "sap_hana_private_ip" {
  description = "The private IP address of the SAP HANA Database VM."
  value       = azurerm_network_interface.vms["vm-hana-${var.environment}-${local.region_code}-01"].private_ip_address
}

output "proximity_placement_group_id" {
  description = "The ID of the Proximity Placement Group for SAP workloads."
  value       = azurerm_proximity_placement_group.sap.id
}

# Storage Outputs
output "diagnostics_storage_account_name" {
  description = "The name of the diagnostics storage account."
  value       = azurerm_storage_account.diagnostics.name
}

output "diagnostics_storage_account_id" {
  description = "The ID of the diagnostics storage account."
  value       = azurerm_storage_account.diagnostics.id
}

# Backup Outputs
output "recovery_vault_name" {
  description = "The name of the Recovery Services Vault."
  value       = azurerm_recovery_services_vault.main.name
}

output "recovery_vault_id" {
  description = "The ID of the Recovery Services Vault."
  value       = azurerm_recovery_services_vault.main.id
}

output "vm_backup_policy_id" {
  description = "The ID of the VM backup policy."
  value       = var.enable_backup ? azurerm_backup_policy_vm.standard[0].id : null
}

output "hana_backup_policy_id" {
  description = "The ID of the HANA backup policy."
  value       = var.enable_backup ? azurerm_backup_policy_vm_workload.hana[0].id : null
}

# Deployment Information
output "deployment_summary" {
  description = "Summary of the deployed SAP S/4HANA infrastructure."
  value = {
    environment           = var.environment
    location              = var.location
    sap_sid               = var.sap_sid
    hub_vnet_address      = local.vnets[local.hub_vnet_name].address_space
    spoke_vnet_address    = local.vnets[local.spoke_vnet_name].address_space
    jump_host_vm_size     = local.virtual_machines["vm-jump-${var.environment}-${local.region_code}-01"].vm_size
    sap_app_vm_size       = local.virtual_machines["vm-s4app-${var.environment}-${local.region_code}-01"].vm_size
    sap_hana_vm_size      = local.virtual_machines["vm-hana-${var.environment}-${local.region_code}-01"].vm_size
    backup_enabled        = var.enable_backup
    accelerated_networking = var.enable_accelerated_networking
  }
}
