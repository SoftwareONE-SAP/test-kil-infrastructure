This is a detailed infrastructure specification for deploying a highly available, secure SAP S/4HANA landscape in a single Azure region.
This design follows the Hub-and-Spoke network topology, which is the Azure standard for enterprise SAP deployments. It ensures security by isolating SAP workloads while allowing managed access via a Jump Host.
1. Executive Summary
Architecture Type: Hub-and-Spoke Topology.
Region: Single Azure Region (e.g., West Europe or East US).
Workload: SAP S/4HANA (Application + HANA Database).
Network Strategy: Strict isolation using Network Security Groups (NSGs) and VNet Peering.
Storage Strategy: Premium SSD v2 for high-performance HANA tier; Standard SSD/Premium SSD for Application tier.
2. Infrastructure Definitions
2.1. Network Topology (Hub & Spoke)
Hub VNet: Contains shared services (Firewall, Jump Host/Bastion, VPN/ExpressRoute Gateway). This acts as the single point of entry.
Spoke VNet (SAP Production): Dedicated VNet for the SAP workloads (App & DB). It is peered to the Hub VNet but does not have direct internet access.
2.2. Virtual Network & IP Planning
We will use a /16 (65,536 IPs) for the entire landscape to ensure room for growth, broken down into smaller subnets.
Address Space: 10.222.0.0/16
vnets = {
    (local.hub_vnet_name) = {
      address_space = ["10.222.212.0/22"]
      subnets = {
        "GatewaySubnet" = {
          address_prefixes = ["10.222.212.0/27"]
        }
        "AzureBastionSubnet" = {
          address_prefixes = ["10.222.212.32/27"]
          # Note: AzureBastionSubnet does not require NSG association per Azure standards
          # Bastion has built-in security controls and manages its own traffic rules
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
3. Compute Specification (VM Sizes)
Sizes are selected based on typical production workload requirements. Note: Exact sizing depends on SAPS ratings calculated during the sizing phase.
3.1. Jump Host (Management)
Role: Secure entry point for administrators.
VM Family: General Purpose (B-series or D-series).
SKU: Standard_D2s_v5 (2 vCPU, 8 GB RAM) or Standard_B2ms.
OS: Windows Server 2022 (typical for admins) or Linux (RHEL/SUSE).
3.2. SAP Application Server (PAS/AAS)
Role: Runs the S/4HANA Application instances.
VM Family: Memory Optimized (E-series) are preferred for S/4HANA applications due to high memory consumption.
SKU: Standard_E16ds_v5 (16 vCPU, 128 GB RAM).
Configuration:
Proximity Placement Group (PPG): Place App and DB VMs in the same PPG to minimize network latency.
Accelerated Networking: Enabled (Critical for SAP performance).
3.3. SAP HANA Database Server
Role: Runs the HANA In-Memory Database.
VM Family: Memory Optimized (M-series is certified for large HANA workloads; E-series for smaller <6TB workloads).
SKU: Standard_M64ls (64 vCPU, 512 GB RAM) OR Standard_E64ds_v5 (for smaller workloads).
Certification: Must be an SAP HANA Certified VM SKU.
Configuration:
Write Accelerator: Enabled (if using M-Series with Premium SSD v1).
Accelerated Networking: Enabled.
4. Storage Specification & Disk Layout
4.1. SAP Application Server Storage
Uses Premium SSD (LRS) for reliability and performance.
Mount Point	Disk Type	Size	Notes
/ (OS)	Premium SSD	128 GB	OS Disk.
/usr/sap	Premium SSD	128 GB	SAP binaries.
/sapmnt	Premium SSD	128 GB	Shared profiles (Consider Azure NetApp Files for HA).
swap	Premium SSD	64 GB	Swap space on a dedicated disk.
4.2. SAP HANA Database Storage
We use Premium SSD v2 (Recommended). It allows you to adjust performance (IOPS/Throughput) independently of capacity, which is cheaper and more performant for HANA.
Assuming a 512GB RAM HANA instance:
Mount Point	Volume Name	Disk Type	Capacity	IOPS (Prov.)	Throughput (Prov.)	File System
Data	/hana/data	Prem SSD v2	640 GB (1.2x RAM)	8,000	400 MB/s	XFS
Log	/hana/log	Prem SSD v2	256 GB (0.5x RAM)	8,000	250 MB/s	XFS
Shared	/hana/shared	Prem SSD v2	512 GB (1x RAM)	3,000	125 MB/s	XFS
Backup	/hana/backup	Standard SSD	2 TB	3,000	N/A	XFS
Note: If Premium SSD v2 is not available in the region, use Premium SSD (v1) with LVM striping (RAID 0) for /hana/data to achieve required IOPS.
5. Networking & Routing Rules
5.1. Route Tables (UDR)
Traffic should be forced through the Hub Firewall for inspection (North-South) but allow direct low-latency communication between App and DB (East-West).
Route Table Name: RT-SAP-Spoke
Default Route: 0.0.0.0/0 -> Next Hop: Virtual Appliance (IP of Azure Firewall in Hub).
Local VNet: 10.20.0.0/16 -> Next Hop: Virtual Network (Allows direct App-to-DB talk).
5.2. Network Security Groups (NSGs)
NSGs act as a distributed firewall at the subnet level.
Subnet: SAP-App-Subnet
Inbound:
Allow TCP 3200-3299 (Dispatcher) from Jump Host / User Network.
Allow TCP 3300-3399 (Gateway) from Jump Host.
Allow TCP 443 (HTTPS) from Gateway Subnet.
Deny All Internet Inbound.
Subnet: SAP-DB-Subnet
Inbound:
Allow TCP 30013, 30015 (HANA SQL) from SAP-App-Subnet.
Allow TCP 22 (SSH) from Jump Host Subnet ONLY.
Deny All other inbound traffic (Strict isolation).
6. Backup & Recovery
6.1. Azure Recovery Services Vault (RSV)
VM Backup: Configure daily snapshots of the Jump Host and App Servers. Retention: 30 days.
HANA Backup: Use Azure Backup for SAP HANA.
This is a certified, backint-integrated streaming backup service.
RPO: 15 minutes (Log backups).
Retention: Daily full backups retained for 30 days; Weekly for 12 weeks; Monthly for 1 year.
6.2. Storage Account
Type: Standard General Purpose v2 (LRS or ZRS).
Purpose: Boot diagnostics, cloud-init logs, and an optional destination for manual HANA file-based backups (/hana/backup).
Summary of Azure Resources to Deploy
Resource Group: rg-sap-prod-001
VNet: vnet-hub-01 (Hub) & vnet-sap-prod-01 (Spoke) + Peering.
Virtual Machines:
1x Jump Host (vm-jumphost)
1x App Servers (vm-s4app-01)
1x HANA DB (vm-hana-01)
Storage: Managed Disks (Prem v2 for HANA), RSV for Backup.
Security: NSGs attached to subnets; Route Table attached to Spoke subnets.
Would you like me to generate the Terraform or Bicep code to deploy this infrastructure automatically?
 