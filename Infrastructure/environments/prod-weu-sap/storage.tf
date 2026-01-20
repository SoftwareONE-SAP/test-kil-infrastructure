# Storage Account for Boot Diagnostics
resource "azurerm_storage_account" "diagnostics" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [
      azurerm_subnet.subnets["${local.hub_vnet_name}/snet-jump-${var.environment}-${local.region_code}-01"].id,
      azurerm_subnet.subnets["${local.spoke_vnet_name}/snet-app-${var.environment}-${local.region_code}-01"].id,
      azurerm_subnet.subnets["${local.spoke_vnet_name}/snet-db-${var.environment}-${local.region_code}-01"].id
    ]
  }

  tags = local.tags
}

# Managed Disks for VMs are created inline with VM resources in compute.tf
# This approach ensures proper lifecycle management and dependency handling
