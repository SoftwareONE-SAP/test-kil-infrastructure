locals {
  location = var.location
  tags     = var.tags

  # Naming conventions
  hub_vnet_name   = "vnet-hub-prod-weu-01"
  spoke_vnet_name = "vnet-sap-prod-weu-01"

  # Resource Group
  resource_group_name = "rg-sap-prod-weu-01"

  # Network Configuration
  vnets = {
    (local.hub_vnet_name) = {
      address_space = ["10.222.212.0/22"]
      subnets = {
        "GatewaySubnet" = {
          address_prefixes = ["10.222.212.0/27"]
        }
        "AzureBastionSubnet" = {
          address_prefixes = ["10.222.212.32/27"]
        }
        "snet-jump-prod-weu-01" = {
          address_prefixes = ["10.222.213.0/28"]
        }
        "AzureFirewallSubnet" = {
          address_prefixes = ["10.222.214.0/26"]
        }
      }
    }
    (local.spoke_vnet_name) = {
      address_space = ["10.222.216.0/22"]
      subnets = {
        "snet-app-prod-weu-01" = {
          address_prefixes  = ["10.222.217.0/24"]
          service_endpoints = ["Microsoft.Storage"]
        }
        "snet-db-prod-weu-01" = {
          address_prefixes  = ["10.222.218.0/24"]
          service_endpoints = ["Microsoft.Storage"]
        }
      }
    }
  }

  # VNet Peering
  vnet_peerings = {
    "hub-to-spoke" = {
      source_vnet_name        = local.hub_vnet_name
      destination_vnet_name   = local.spoke_vnet_name
      allow_forwarded_traffic = true
      allow_gateway_transit   = true
      use_remote_gateways     = false
    }
  }

  # NSG Rules
  nsg_rules = {
    "app-nsg" = {
      rules = {
        "allow-dispatcher" = {
          name                       = "allow-dispatcher"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["3200-3299"]
          source_address_prefix      = "10.222.213.0/28"
          destination_address_prefix = "*"
        }
        "allow-gateway" = {
          name                       = "allow-gateway"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["3300-3399"]
          source_address_prefix      = "10.222.213.0/28"
          destination_address_prefix = "*"
        }
        "allow-https" = {
          name                       = "allow-https"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "10.222.212.0/27"
          destination_address_prefix = "*"
        }
      }
    }
    "db-nsg" = {
      rules = {
        "allow-hana-sql" = {
          name                       = "allow-hana-sql"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = ["30013", "30015"]
          source_address_prefix      = "10.222.217.0/24"
          destination_address_prefix = "*"
        }
        "allow-ssh" = {
          name                       = "allow-ssh"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.222.213.0/28"
          destination_address_prefix = "*"
        }
      }
    }
  }

  # Route Table
  route_table = {
    "sap-spoke-rt" = {
      routes = {
        "default" = {
          name                   = "default"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.222.214.4"
        }
      }
    }
  }

  # Storage Account
  storage_account = {
    name                     = "stdiagweu01"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }

  # VM Configuration
  virtual_machines = {
    "vm-jumphost" = {
      size                = "Standard_D2s_v5"
      subnet_name         = "snet-jump-prod-weu-01"
      enable_accelerated_networking = false
    }
    "vm-s4app-01" = {
      size                = "Standard_E16ds_v5"
      subnet_name         = "snet-app-prod-weu-01"
      enable_accelerated_networking = true
    }
    "vm-hana-01" = {
      size                = "Standard_M64ls"
      subnet_name         = "snet-db-prod-weu-01"
      enable_accelerated_networking = true
    }
  }

  # Disks Configuration
  disks = {
    "disk-jumphost-os" = {
      name                 = "disk-jumphost-os"
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 128
    }
    "disk-s4app-os" = {
      name                 = "disk-s4app-os"
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 128
    }
    "disk-s4app-data" = {
      name                 = "disk-s4app-data"
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 128
    }
    "disk-hana-os" = {
      name                 = "disk-hana-os"
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 128
    }
    "disk-hana-data" = {
      name                 = "disk-hana-data"
      storage_account_type = "PremiumV2_LRS"
      disk_size_gb         = 640
    }
    "disk-hana-log" = {
      name                 = "disk-hana-log"
      storage_account_type = "PremiumV2_LRS"
      disk_size_gb         = 256
    }
    "disk-hana-shared" = {
      name                 = "disk-hana-shared"
      storage_account_type = "PremiumV2_LRS"
      disk_size_gb         = 512
    }
    "disk-hana-backup" = {
      name                 = "disk-hana-backup"
      storage_account_type = "StandardSSD_LRS"
      disk_size_gb         = 2048
    }
  }

  # Backup Configuration
  backup_config = {
    rsv_name = "rsv-sap-prod-weu-01"
    rsv_sku  = "Standard"
  }

  # VM Backup Policies (defined in backup.tf to avoid circular dependencies)
  vm_backup_policies = {}

  # SAP HANA Backup Policy (defined in backup.tf to avoid circular dependencies)
  hana_backup_policy = {}
}