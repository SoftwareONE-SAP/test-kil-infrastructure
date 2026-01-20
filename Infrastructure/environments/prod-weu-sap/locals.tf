locals {
  # Naming convention components
  region_code = "weu"
  project     = "sap"

  # Common tags applied to all resources
  tags = {
    Environment  = var.environment
    Project      = "SAP-S4HANA"
    CostCentre   = var.cost_centre
    ManagedBy    = "Terraform"
    SAP_SID      = var.sap_sid
    Workload     = "SAP"
    Criticality  = "High"
    DeployedDate = timestamp()
  }

  # Resource Group
  resource_group_name = "rg-${local.project}-${var.environment}-${local.region_code}-01"

  # VNet names
  hub_vnet_name   = "vnet-hub-${var.environment}-${local.region_code}-01"
  spoke_vnet_name = "vnet-${local.project}-${var.environment}-${local.region_code}-01"

  # Virtual Networks configuration
  vnets = {
    (local.hub_vnet_name) = {
      address_space = ["10.222.212.0/22"]
      subnets = {
        "GatewaySubnet" = {
          address_prefixes  = ["10.222.212.0/27"]
          nsg_name          = null # Gateway subnet does not use NSG
          route_table_name  = null
          service_endpoints = []
        }
        "AzureBastionSubnet" = {
          address_prefixes  = ["10.222.212.32/27"]
          nsg_name          = null # Bastion manages its own security
          route_table_name  = null
          service_endpoints = []
        }
        "snet-jump-${var.environment}-${local.region_code}-01" = {
          address_prefixes  = ["10.222.213.0/28"]
          nsg_name          = "nsg-jump-${var.environment}-${local.region_code}-01"
          route_table_name  = null
          service_endpoints = []
        }
        "AzureFirewallSubnet" = {
          address_prefixes  = ["10.222.214.0/26"]
          nsg_name          = null # Firewall subnet does not use NSG
          route_table_name  = null
          service_endpoints = []
        }
      }
    }
    (local.spoke_vnet_name) = {
      address_space = ["10.222.216.0/22"]
      subnets = {
        "snet-app-${var.environment}-${local.region_code}-01" = {
          address_prefixes  = ["10.222.217.0/24"]
          nsg_name          = "nsg-app-${var.environment}-${local.region_code}-01"
          route_table_name  = "rt-${local.project}-spoke-${var.environment}-${local.region_code}"
          service_endpoints = ["Microsoft.Storage"]
        }
        "snet-db-${var.environment}-${local.region_code}-01" = {
          address_prefixes  = ["10.222.218.0/24"]
          nsg_name          = "nsg-db-${var.environment}-${local.region_code}-01"
          route_table_name  = "rt-${local.project}-spoke-${var.environment}-${local.region_code}"
          service_endpoints = ["Microsoft.Storage"]
        }
      }
    }
  }

  # VNet Peering configuration
  vnet_peerings = {
    "hub-to-spoke" = {
      source_vnet_name        = local.hub_vnet_name
      destination_vnet_name   = local.spoke_vnet_name
      allow_forwarded_traffic = true
      allow_gateway_transit   = true
      use_remote_gateways     = false
    }
    "spoke-to-hub" = {
      source_vnet_name        = local.spoke_vnet_name
      destination_vnet_name   = local.hub_vnet_name
      allow_forwarded_traffic = true
      allow_gateway_transit   = false
      use_remote_gateways     = false
    }
  }

  # Network Security Groups - Jump Host Subnet
  nsg_rules_jump = {
    "Allow-RDP-Inbound" = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
    }
    "Allow-SSH-Inbound" = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
    }
    "Deny-All-Inbound" = {
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # Network Security Groups - SAP Application Subnet
  nsg_rules_app = {
    "Allow-SAP-Dispatcher-From-Jump" = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3200-3299"
      source_address_prefix      = "10.222.213.0/28"
      destination_address_prefix = "*"
    }
    "Allow-SAP-Gateway-From-Jump" = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3300-3399"
      source_address_prefix      = "10.222.213.0/28"
      destination_address_prefix = "*"
    }
    "Allow-HTTPS-From-Jump" = {
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "10.222.213.0/28"
      destination_address_prefix = "*"
    }
    "Allow-SSH-From-Jump" = {
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.222.213.0/28"
      destination_address_prefix = "*"
    }
    "Allow-From-DB-Subnet" = {
      priority                   = 140
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.222.218.0/24"
      destination_address_prefix = "*"
    }
    "Deny-Internet-Inbound" = {
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
    }
  }

  # Network Security Groups - SAP HANA Database Subnet
  nsg_rules_db = {
    "Allow-HANA-SQL-From-App" = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "30013-30015"
      source_address_prefix      = "10.222.217.0/24"
      destination_address_prefix = "*"
    }
    "Allow-SSH-From-Jump" = {
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.222.213.0/28"
      destination_address_prefix = "*"
    }
    "Allow-From-App-Subnet" = {
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.222.217.0/24"
      destination_address_prefix = "*"
    }
    "Deny-All-Other-Inbound" = {
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  # Route Table for Spoke VNet (force traffic through Hub Firewall)
  route_tables = {
    "rt-${local.project}-spoke-${var.environment}-${local.region_code}" = {
      routes = {
        "default-via-firewall" = {
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.222.214.4" # Azure Firewall private IP
        }
        "local-vnet-direct" = {
          address_prefix         = "10.222.216.0/22"
          next_hop_type          = "VnetLocal"
          next_hop_in_ip_address = null
        }
      }
    }
  }

  # Proximity Placement Group for low-latency SAP workloads
  proximity_placement_group_name = "ppg-${local.project}-${var.environment}-${local.region_code}-01"

  # Virtual Machines configuration
  virtual_machines = {
    "vm-jump-${var.environment}-${local.region_code}-01" = {
      vm_size               = "Standard_D2s_v5"
      zone                  = "1"
      subnet_key            = "snet-jump-${var.environment}-${local.region_code}-01"
      vnet_key              = local.hub_vnet_name
      os_type               = "Linux"
      os_disk_size_gb       = 128
      os_disk_storage_type  = "Premium_LRS"
      enable_accelerated_networking = false
      use_ppg               = false
      data_disks            = []
      enable_backup         = var.enable_backup
      backup_policy_id      = "vm-standard"
    }
    "vm-s4app-${var.environment}-${local.region_code}-01" = {
      vm_size               = "Standard_E16ds_v5"
      zone                  = "1"
      subnet_key            = "snet-app-${var.environment}-${local.region_code}-01"
      vnet_key              = local.spoke_vnet_name
      os_type               = "Linux"
      os_disk_size_gb       = 128
      os_disk_storage_type  = "Premium_LRS"
      enable_accelerated_networking = var.enable_accelerated_networking
      use_ppg               = true
      data_disks = [
        {
          name         = "disk-s4app-usrsap-${var.environment}-${local.region_code}-01"
          size_gb      = 128
          storage_type = "Premium_LRS"
          lun          = 0
          caching      = "ReadWrite"
        },
        {
          name         = "disk-s4app-sapmnt-${var.environment}-${local.region_code}-01"
          size_gb      = 128
          storage_type = "Premium_LRS"
          lun          = 1
          caching      = "ReadWrite"
        },
        {
          name         = "disk-s4app-swap-${var.environment}-${local.region_code}-01"
          size_gb      = 64
          storage_type = "Premium_LRS"
          lun          = 2
          caching      = "None"
        }
      ]
      enable_backup    = var.enable_backup
      backup_policy_id = "vm-standard"
    }
    "vm-hana-${var.environment}-${local.region_code}-01" = {
      vm_size               = "Standard_E64ds_v5"
      zone                  = "1"
      subnet_key            = "snet-db-${var.environment}-${local.region_code}-01"
      vnet_key              = local.spoke_vnet_name
      os_type               = "Linux"
      os_disk_size_gb       = 128
      os_disk_storage_type  = "Premium_LRS"
      enable_accelerated_networking = var.enable_accelerated_networking
      use_ppg               = true
      data_disks = [
        {
          name                      = "disk-hana-data-${var.environment}-${local.region_code}-01"
          size_gb                   = 640
          storage_type              = "PremiumV2_LRS"
          lun                       = 0
          caching                   = "None"
          disk_iops_read_write      = 8000
          disk_mbps_read_write      = 400
        },
        {
          name                      = "disk-hana-log-${var.environment}-${local.region_code}-01"
          size_gb                   = 256
          storage_type              = "PremiumV2_LRS"
          lun                       = 1
          caching                   = "None"
          disk_iops_read_write      = 8000
          disk_mbps_read_write      = 250
        },
        {
          name                      = "disk-hana-shared-${var.environment}-${local.region_code}-01"
          size_gb                   = 512
          storage_type              = "PremiumV2_LRS"
          lun                       = 2
          caching                   = "None"
          disk_iops_read_write      = 3000
          disk_mbps_read_write      = 125
        },
        {
          name         = "disk-hana-backup-${var.environment}-${local.region_code}-01"
          size_gb      = 2048
          storage_type = "StandardSSD_LRS"
          lun          = 3
          caching      = "None"
        }
      ]
      enable_backup    = var.enable_backup
      backup_policy_id = "hana-certified"
    }
  }

  # Storage Account for diagnostics
  storage_account_name = "st${local.project}diag${var.environment}${local.region_code}01"

  # Recovery Services Vault
  recovery_vault_name = "rsv-${local.project}-${var.environment}-${local.region_code}-01"

  # Backup Policies
  backup_policies = {
    "vm-standard" = {
      type     = "vm"
      timezone = "UTC"
      backup = {
        frequency = "Daily"
        time      = "23:00"
      }
      retention_daily = {
        count = 30
      }
      retention_weekly = {
        count    = 12
        weekdays = ["Sunday"]
      }
      retention_monthly = {
        count    = 12
        weekdays = ["Sunday"]
        weeks    = ["First"]
      }
    }
    "hana-certified" = {
      type     = "hana"
      timezone = "UTC"
      backup = {
        frequency_in_minutes = 15
        time                 = "23:00"
      }
      retention_daily = {
        count = 30
      }
      retention_weekly = {
        count    = 12
        weekdays = ["Sunday"]
      }
      retention_monthly = {
        count    = 12
        weekdays = ["Sunday"]
        weeks    = ["First"]
      }
      retention_yearly = {
        count    = 1
        weekdays = ["Sunday"]
        weeks    = ["First"]
        months   = ["January"]
      }
    }
  }
}
