Here is the complete **Unified Master Terraform Standard** formatted as a Markdown file. You can copy the content below and save it as `terraform_standards.md`.

```markdown
# Unified Master Terraform Coding Standards

**Version:** 2.0 (Unified Master)  
**Status:** Enforced  
**Target Audience:** Infrastructure Engineers & AI Assistants  
**Scope:** Azure Infrastructure as Code  

---

## 1. Guiding Principles for AI Generation

To ensure consistency when generating code, all AI agents and engineers must adhere to these core directives:

1.  **Strict Object-Based Configuration:** Modules must accept a single complex object variable (e.g., `vm_config`) rather than dozens of loose variables.
2.  **Locals-First Architecture:** `main.tf` is for resource declaration logic only. All configuration data, maps, and literals must reside in `locals.tf`.
3.  **Zero Hardcoding:** Never place Subscription IDs, Tenant IDs, or IP addresses in `main.tf`. Use variables or `data` sources.
4.  **Explicit Outputs:** Every module must output the Resource ID and (if applicable) the Managed Identity Principal ID.

---

## 2. Project Structure

The repository must follow a strict directory hierarchy to separate reusable logic from environment data.

### 2.1 Directory Layout

```text
Infrastructure/
├── modules/                        # Reusable logic ONLY
│   ├── swo_azurerm_linux_vm/       # Prefix custom modules with 'swo_'
│   ├── swo_azurerm_keyvault/
│   └── swo_azurerm_network/
├── environments/                   # Environment specific usage
│   ├── prod-uksouth/
│   │   ├── main.tf                 # Provider & Backend definition
│   │   ├── locals.tf               # ALL configuration data
│   │   ├── network.tf              # Resource instantiation
│   │   ├── compute.tf
│   │   └── variables.tf
│   └── nonprod-ukwest/
└── scripts/                        # Bootstrap & maintenance scripts

```

---

## 3. Module Design Standards

### 3.1 Module Input Pattern (The "Object" Rule)

**Rule:** Modules must NOT use loose variables for resource properties. Use a single typed object.

**✅ DO:**

```hcl
# modules/swo_azurerm_linux_vm/variables.tf
variable "vm_config" {
  description = "Primary configuration object for the Linux VM."
  type = object({
    name                = string
    size                = optional(string, "Standard_D2s_v5") # Intelligent default
    location            = string
    subnet_id           = string
    enable_backup       = optional(bool, true)
    tags                = map(string)
  })
}

```

**❌ DO NOT:**

```hcl
variable "vm_name" { ... }
variable "vm_size" { ... }
variable "vm_location" { ... }

```

### 3.2 Module Output Contract

**Rule:** Every module must output the following minimal set to ensure chainability.

```hcl
# modules/swo_azurerm_linux_vm/outputs.tf
output "id" {
  description = "The Resource ID of the Virtual Machine."
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "The Name of the Virtual Machine."
  value       = azurerm_linux_virtual_machine.this.name
}

output "identity_principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity."
  value       = try(azurerm_linux_virtual_machine.this.identity[0].principal_id, null)
}

```

### 3.3 Documentation

**Rule:** Every module must contain a `README.md`.

* AI Agents must generate this file automatically, including a "Usage" example block.

---

## 4. Configuration & Naming

### 4.1 "Locals-First" Instantiation

**Rule:** Do not define resources with literal strings in `main.tf`. Define the data in `locals` and iterate.

**✅ DO:**

```hcl
# environments/prod-uksouth/locals.tf
locals {
  virtual_machines = {
    "app-server-01" = {
      size = "Standard_D4s_v5"
      zone = 1
    }
    "app-server-02" = {
      size = "Standard_D4s_v5"
      zone = 2
    }
  }
}

# environments/prod-uksouth/compute.tf
module "linux_vms" {
  source   = "../../modules/swo_azurerm_linux_vm"
  for_each = local.virtual_machines
  
  vm_config = {
    name      = each.key
    size      = each.value.size
    location  = local.location
    subnet_id = module.network.subnet_ids["app"]
    tags      = local.tags
  }
}

```

### 4.2 Naming Conventions (CAF Aligned)

**Rule:** All names must be lowercase and follow the pattern:
`[resource_type]-[project]-[env]-[region]-[instance]`

| Resource Type | Abbreviation | Example |
| --- | --- | --- |
| Resource Group | `rg` | `rg-gpms-prod-uks-01` |
| Virtual Network | `vnet` | `vnet-gpms-prod-uks-01` |
| Subnet | `snet` | `snet-gpms-prod-uks-app` |
| Key Vault | `kv` | `kv-gpms-prod-uks-01` |
| Storage Account | `st` | `stgpmsproduks01` (No hyphens) |
| Virtual Machine | `vm` | `vm-app-prod-01` |

---

## 5. State & Security

### 5.1 Remote State Configuration (Partial Config)

**Rule:** **NEVER** hardcode Subscription or Tenant IDs in the `backend` block. Use partial configuration or file-based init.

**✅ DO (Code):**

```hcl
# environments/prod-uksouth/main.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-mgmt"
    storage_account_name = "sttfstatemgmt01"
    container_name       = "tfstate"
    key                  = "prod-uksouth-network.tfstate"
    # subscription_id is OMITTED here for security
  }
}

```

### 5.2 Secrets Management

**Rule:** No secrets in code.

1. **Input:** Pass secrets via variables marked `sensitive = true`.
2. **Retrieval:** Use `data "azurerm_key_vault_secret"` to fetch passwords/keys at runtime.

**✅ DO:**

```hcl
data "azurerm_key_vault" "secrets" {
  name                = "kv-gpms-prod-uks-01"
  resource_group_name = "rg-gpms-prod-uks-sec"
}

data "azurerm_key_vault_secret" "vm_admin" {
  name         = "vm-admin-password"
  key_vault_id = data.azurerm_key_vault.secrets.id
}

```

---

## 6. Validation & Quality Control

### 6.1 Validation Blocks

**Rule:** All input variables must have validation blocks where format is critical (e.g., naming or sizing).

```hcl
variable "storage_config" {
  type = object({
    name = string
    tier = string
  })

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_config.name))
    error_message = "Storage account name must be 3-24 lowercase alphanumeric characters."
  }
}

```

### 6.2 Pre-Commit Checklist

Before finalizing code, the AI/Engineer must verify:

* [ ] `terraform fmt -recursive` has been run.
* [ ] No hardcoded IP addresses (use CIDR math or variables).
* [ ] No hardcoded Subscription IDs.
* [ ] All modules have a README.
* [ ] `versions.tf` exists in all modules with constraints:
```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

```
