# Plan: prod-weu-sap Terraform Implementation

This plan translates the requirements in [`requirements-defined.md`](environments/prod-weu-sap/requirements-defined.md) into a standards-compliant Terraform implementation following [`Session-prompt.md`](environments/prod-weu-sap/Session-prompt.md) and [`terraform-standards.md`](environments/prod-weu-sap/terraform-standards.md).

---

## 1. Scope & Assumptions

- Target cloud: Azure
- Terraform version: >= 1.5.0
- Provider: [`azurerm`](hashicorp/azurerm)
- Topology: Hub-and-Spoke, single region (West Europe assumed via locals)
- No existing reusable modules are assumed to be compliant; modules will be created or updated as required.
- Environment code will **only** wire modules and define locals, variables, backend, and provider configuration.

---

## 2. Repository Changes Overview

### 2.1 New / Updated Modules (in creation order)

All modules live under [`Infrastructure/modules/`](modules/).

1. **Network Modules**
   - `swo_azurerm_virtual_network`
   - `swo_azurerm_subnet`
   - `swo_azurerm_network_security_group`
   - `swo_azurerm_route_table`
   - `swo_azurerm_vnet_peering`

2. **Storage Modules**
   - `swo_azurerm_storage_account`
   - `swo_azurerm_managed_disk`

3. **Compute Modules**
   - `swo_azurerm_linux_vm`
   - `swo_azurerm_windows_vm`
   - `swo_azurerm_network_interface`
   - `swo_azurerm_proximity_placement_group`

4. **Backup Modules**
   - `swo_azurerm_recovery_services_vault`
   - `swo_azurerm_vm_backup_policy`
   - `swo_azurerm_sap_hana_backup`

Each module will contain:
- [`versions.tf`](versions.tf)
- [`variables.tf`](variables.tf) (single object input)
- [`main.tf`](main.tf)
- [`outputs.tf`](outputs.tf)
- [`README.md`](README.md)

---

## 3. Environment Files to Generate

Path: [`environments/prod-weu-sap/`](environments/prod-weu-sap/)

Generated in **strict order**:

1. [`versions.tf`](environments/prod-weu-sap/versions.tf)
   - Terraform version constraint
   - AzureRM provider constraint

2. [`variables.tf`](environments/prod-weu-sap/variables.tf)
   - Environment-level inputs (region, naming prefix, tags)
   - Sensitive inputs (admin credentials, fetched via Key Vault)

3. [`locals.tf`](environments/prod-weu-sap/locals.tf)
   - Naming conventions (CAF-aligned)
   - Region and environment metadata
   - Full network topology map (VNets, subnets, CIDRs)
   - VM definitions (Jump, App, HANA)
   - Disk layouts and performance settings
   - Backup policies

4. [`network.tf`](environments/prod-weu-sap/network.tf)
   - Instantiate hub and spoke VNets
   - Create subnets
   - Attach NSGs and route tables
   - Configure VNet peering

5. [`storage.tf`](environments/prod-weu-sap/storage.tf)
   - Storage account for diagnostics and backups
   - Managed disks for SAP App and HANA (Premium SSD v2 where applicable)

6. [`compute.tf`](environments/prod-weu-sap/compute.tf)
   - Proximity Placement Group
   - NICs per VM
   - Jump Host VM (Windows or Linux)
   - SAP App VM
   - SAP HANA VM

7. [`backup.tf`](environments/prod-weu-sap/backup.tf)
   - Recovery Services Vault
   - VM backup policies
   - SAP HANA backup configuration

8. [`outputs.tf`](environments/prod-weu-sap/outputs.tf)
   - Key outputs (VNet IDs, VM IDs, RSV ID)

---

## 4. Mapping Requirements → Terraform

### 4.1 Network

- Address space: `10.222.0.0/16`
- Hub VNet: `10.222.212.0/22`
- Spoke VNet: `10.222.216.0/22`
- Subnets exactly as defined in [`requirements-defined.md`](environments/prod-weu-sap/requirements-defined.md)
- NSGs:
  - App subnet: SAP dispatcher, gateway, HTTPS
  - DB subnet: HANA SQL + SSH from jump only
- Route table forcing `0.0.0.0/0` via Azure Firewall IP (passed as variable)

### 4.2 Compute

- Jump Host:
  - Size: `Standard_D2s_v5`
  - Subnet: Jump subnet in Hub VNet

- SAP App:
  - Size: `Standard_E16ds_v5`
  - Accelerated networking enabled

- SAP HANA:
  - Size: `Standard_M64ls` or `Standard_E64ds_v5` (variable-driven)
  - Accelerated networking enabled

- App + DB placed in same Proximity Placement Group

### 4.3 Storage

- App disks: Premium SSD (OS, /usr/sap, /sapmnt, swap)
- HANA disks:
  - Premium SSD v2 for data, log, shared
  - Standard SSD for backup
  - Performance parameters driven from locals

### 4.4 Backup

- Recovery Services Vault
- Daily VM backups (30-day retention)
- SAP HANA Azure Backup with log backups every 15 minutes

---

## 5. Validation Checklist (for Code Agent)

- [ ] All modules follow single-object input rule
- [ ] No `azurerm_*` resources in environment files
- [ ] All naming follows CAF convention
- [ ] No hardcoded subscription IDs or secrets
- [ ] `terraform init` succeeds with partial backend config
- [ ] `terraform validate` passes cleanly

---

## 6. Next Step

Proceed to **Code mode** and implement modules first (Network → Storage → Compute → Backup), then generate environment code exactly following the file order defined in [`Session-prompt.md`](environments/prod-weu-sap/Session-prompt.md).