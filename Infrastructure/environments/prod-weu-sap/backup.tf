# Recovery Services Vault
resource "azurerm_recovery_services_vault" "main" {
  name                = local.recovery_vault_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
  soft_delete_enabled = true

  tags = local.tags
}

# VM Backup Policy (Standard)
resource "azurerm_backup_policy_vm" "standard" {
  count = var.enable_backup ? 1 : 0

  name                = "policy-vm-standard"
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  timezone = local.backup_policies["vm-standard"].timezone

  backup {
    frequency = local.backup_policies["vm-standard"].backup.frequency
    time      = local.backup_policies["vm-standard"].backup.time
  }

  retention_daily {
    count = local.backup_policies["vm-standard"].retention_daily.count
  }

  retention_weekly {
    count    = local.backup_policies["vm-standard"].retention_weekly.count
    weekdays = local.backup_policies["vm-standard"].retention_weekly.weekdays
  }

  retention_monthly {
    count    = local.backup_policies["vm-standard"].retention_monthly.count
    weekdays = local.backup_policies["vm-standard"].retention_monthly.weekdays
    weeks    = local.backup_policies["vm-standard"].retention_monthly.weeks
  }
}

# VM Backup Protection - Jump Host
resource "azurerm_backup_protected_vm" "jump" {
  count = var.enable_backup ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  source_vm_id        = azurerm_linux_virtual_machine.jump.id
  backup_policy_id    = azurerm_backup_policy_vm.standard[0].id
}

# VM Backup Protection - SAP Application Server
resource "azurerm_backup_protected_vm" "app" {
  count = var.enable_backup ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  source_vm_id        = azurerm_linux_virtual_machine.app.id
  backup_policy_id    = azurerm_backup_policy_vm.standard[0].id
}

# SAP HANA Backup Configuration
# Note: SAP HANA backup requires the Azure Backup agent to be installed on the HANA VM
# and the HANA database to be registered with the Recovery Services Vault.
# This is typically done post-deployment via Azure Backup for SAP HANA feature.
# The following resources prepare the vault and policy for HANA backup.

# HANA Backup Policy
resource "azurerm_backup_policy_vm_workload" "hana" {
  count = var.enable_backup ? 1 : 0

  name                = "policy-hana-certified"
  resource_group_name = azurerm_resource_group.main.name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  workload_type       = "SAPHanaDatabase"

  settings {
    time_zone           = local.backup_policies["hana-certified"].timezone
    compression_enabled = true
  }

  protection_policy {
    policy_type = "Full"

    backup {
      frequency = "Daily"
      time      = local.backup_policies["hana-certified"].backup.time
    }

    retention_daily {
      count = local.backup_policies["hana-certified"].retention_daily.count
    }

    retention_weekly {
      count    = local.backup_policies["hana-certified"].retention_weekly.count
      weekdays = local.backup_policies["hana-certified"].retention_weekly.weekdays
    }

    retention_monthly {
      count       = local.backup_policies["hana-certified"].retention_monthly.count
      format_type = "Weekly"
      weekdays    = local.backup_policies["hana-certified"].retention_monthly.weekdays
      weeks       = local.backup_policies["hana-certified"].retention_monthly.weeks
    }

    retention_yearly {
      count       = local.backup_policies["hana-certified"].retention_yearly.count
      format_type = "Weekly"
      weekdays    = local.backup_policies["hana-certified"].retention_yearly.weekdays
      weeks       = local.backup_policies["hana-certified"].retention_yearly.weeks
      months      = local.backup_policies["hana-certified"].retention_yearly.months
    }
  }

  protection_policy {
    policy_type = "Log"

    backup {
      frequency_in_minutes = local.backup_policies["hana-certified"].backup.frequency_in_minutes
    }

    simple_retention {
      count = 30
    }
  }
}

# Note: The actual HANA database backup protection must be configured after:
# 1. HANA is installed on the VM
# 2. Azure Backup pre-registration script is run on the HANA VM
# 3. HANA database is discovered in the Recovery Services Vault
# 4. Backup is configured via Azure Portal or CLI for the specific HANA instance
# This cannot be fully automated via Terraform as it requires HANA to be running.
