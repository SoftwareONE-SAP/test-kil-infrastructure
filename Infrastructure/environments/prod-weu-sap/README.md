# SAP S/4HANA Production Environment - West Europe

## Overview

This Terraform configuration deploys a production-ready SAP S/4HANA landscape in Azure West Europe using a **Hub-and-Spoke network topology**. The infrastructure is designed for high availability, security, and performance in accordance with SAP on Azure best practices.

## Architecture

### Network Topology
- **Hub VNet** (`10.222.212.0/22`): Contains shared services
  - Gateway Subnet
  - Azure Bastion Subnet
  - Jump Host Subnet
  - Azure Firewall Subnet
- **Spoke VNet** (`10.222.216.0/22`): Dedicated SAP workload isolation
  - Application Subnet (`10.222.217.0/24`)
  - Database Subnet (`10.222.218.0/24`)

### Compute Resources
| VM | Size | Role | Zone |
|----|------|------|------|
| `vm-jump-prod-weu-01` | Standard_D2s_v5 | Jump Host | 1 |
| `vm-s4app-prod-weu-01` | Standard_E16ds_v5 | SAP Application Server | 1 |
| `vm-hana-prod-weu-01` | Standard_E64ds_v5 | SAP HANA Database | 1 |

### Storage Configuration

#### SAP Application Server
- OS Disk: 128 GB Premium SSD
- `/usr/sap`: 128 GB Premium SSD
- `/sapmnt`: 128 GB Premium SSD
- Swap: 64 GB Premium SSD

#### SAP HANA Database
- OS Disk: 128 GB Premium SSD
- `/hana/data`: 640 GB Premium SSD v2 (8000 IOPS, 400 MB/s)
- `/hana/log`: 256 GB Premium SSD v2 (8000 IOPS, 250 MB/s)
- `/hana/shared`: 512 GB Premium SSD v2 (3000 IOPS, 125 MB/s)
- `/hana/backup`: 2048 GB Standard SSD

### Security

#### Network Security Groups
- **Jump Subnet**: RDP/SSH from VirtualNetwork only
- **App Subnet**: SAP ports (3200-3399, 443) from Jump Host; full access from DB subnet
- **DB Subnet**: HANA SQL ports (30013-30015) from App subnet; SSH from Jump Host only

#### Route Tables
- Default route (`0.0.0.0/0`) forced through Azure Firewall (`10.222.214.4`)
- Local VNet traffic (`10.222.216.0/22`) remains direct for low latency

### Backup & Recovery
- **Recovery Services Vault**: `rsv-sap-prod-weu-01`
- **VM Backup**: Daily at 23:00 UTC, 30-day retention
- **HANA Backup**: Log backups every 15 minutes, daily full backups, yearly retention

## Prerequisites

1. **Azure Subscription** with appropriate permissions
2. **Terraform** >= 1.5.0
3. **Azure CLI** authenticated
4. **Remote State Storage** configured:
   - Resource Group: `rg-tfstate-mgmt`
   - Storage Account: `sttfstatemgmt01`
   - Container: `tfstate`

## Deployment

### 1. Initialize Terraform

```bash
terraform init \
  -backend-config="subscription_id=<YOUR_SUBSCRIPTION_ID>"
```

### 2. Create Variable Values File

Create `terraform.tfvars`:

```hcl
location     = "westeurope"
environment  = "prod"
sap_sid      = "S4H"
cost_centre  = "CC-SAP-001"

admin_username = "azureadmin"
admin_password = "<RETRIEVE_FROM_KEY_VAULT>"
ssh_public_key = "<YOUR_SSH_PUBLIC_KEY>"

enable_backup               = true
enable_accelerated_networking = true
```

**Security Note**: Never commit `terraform.tfvars` to version control. Use Azure Key Vault or environment variables for sensitive values.

### 3. Plan Deployment

```bash
terraform plan -out=tfplan
```

### 4. Apply Configuration

```bash
terraform apply tfplan
```

### 5. Post-Deployment Steps

#### SAP HANA Backup Configuration
1. Install Azure Backup pre-registration script on HANA VM:
   ```bash
   wget https://aka.ms/ScriptForPermsOnHANA -O msawb-plugin-config-com-sap-hana.sh
   bash msawb-plugin-config-com-sap-hana.sh -sk SYSTEM -sn <SID>
   ```

2. Discover HANA database in Recovery Services Vault:
   ```bash
   az backup container list \
     --resource-group rg-sap-prod-weu-01 \
     --vault-name rsv-sap-prod-weu-01 \
     --backup-management-type AzureWorkload
   ```

3. Configure backup via Azure Portal or CLI

## Compliance & Standards

This deployment adheres to:
- ✅ **Unified Master Terraform Coding Standards v2.0**
- ✅ **Azure Cloud Adoption Framework (CAF)** naming conventions
- ✅ **SAP on Azure** reference architecture
- ✅ **Locals-first** configuration pattern
- ✅ **Object-based** variable design
- ✅ **Zero hardcoding** principle

## Outputs

Key outputs available after deployment:

```hcl
terraform output jump_host_private_ip
terraform output sap_app_private_ip
terraform output sap_hana_private_ip
terraform output deployment_summary
```

## Maintenance

### Updating VM Sizes
Modify [`locals.tf`](locals.tf) `virtual_machines` object and re-apply.

### Adding NSG Rules
Update [`locals.tf`](locals.tf) `nsg_rules_*` maps and re-apply.

### Scaling
To add additional application servers, extend the `virtual_machines` map in [`locals.tf`](locals.tf).

## Disaster Recovery

- VM snapshots: Automated via Azure Backup
- HANA backups: Stored in Recovery Services Vault
- RPO: 15 minutes (HANA log backups)
- RTO: Dependent on restore size (typically 2-4 hours for full restore)

## Cost Optimization

- Use Azure Hybrid Benefit for SUSE/RHEL licenses
- Consider Reserved Instances for production VMs (up to 72% savings)
- Review Premium SSD v2 IOPS/throughput settings quarterly

## Support

For issues or questions:
1. Review Terraform plan output
2. Check Azure Activity Log for deployment errors
3. Validate NSG rules and route tables
4. Contact SAP Basis team for application-layer issues

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-20 | Initial production deployment |

---

**Deployed by**: Terraform  
**Managed by**: Infrastructure Team  
**Criticality**: High  
**SAP SID**: S4H
