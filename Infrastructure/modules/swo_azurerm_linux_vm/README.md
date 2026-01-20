# swo_azurerm_linux_vm

## Purpose
This module creates an Azure Linux Virtual Machine with optional data disks using an object-based input pattern. It is designed for reuse across multiple environments and adheres to the Unified Master Terraform Coding Standards.

## Inputs

| Name | Type | Description | Required |
|------|------|-------------|----------|
| vm_config | object | Primary configuration object for the Linux Virtual Machine. | Yes |
| os_disk_config | object | Configuration object for the OS disk. | No |
| data_disks | map(object) | Map of data disks to attach to the VM. | No |
| source_image_reference | object | Source image reference for the VM. | No |

### vm_config Object Schema

```hcl
{
  name                = string
  location            = string
  resource_group_name = string
  size                = string
  admin_username      = string
  subnet_id           = string
  proximity_placement_group_id = optional(string)
  enable_accelerated_networking = optional(bool, false)
  tags                = optional(map(string), {})
}
```

### os_disk_config Object Schema

```hcl
{
  caching              = string
  storage_account_type = string
  disk_size_gb         = number
}
```

### data_disks Map Schema

```hcl
{
  name                 = string
  disk_id              = string
  caching              = string
  lun                  = number
  storage_account_type = string
  disk_size_gb         = number
}
```

### source_image_reference Object Schema

```hcl
{
  publisher = string
  offer     = string
  sku       = string
  version   = string
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | The Resource ID of the Virtual Machine. |
| name | The Name of the Virtual Machine. |
| identity_principal_id | The Principal ID of the System Assigned Managed Identity. |
| network_interface_id | The Resource ID of the Network Interface. |

## Usage Example

```hcl
module "sap_app_vm" {
  source = "../../modules/swo_azurerm_linux_vm"

  vm_config = {
    name                = "vm-s4app-01"
    location            = "westeurope"
    resource_group_name = "rg-sap-prod-weu-01"
    size                = "Standard_E16ds_v5"
    admin_username      = "azureadmin"
    subnet_id           = module.app_subnet.id
    proximity_placement_group_id = module.sap_ppg.id
    enable_accelerated_networking = true
    tags = {
      Environment = "Production"
      Owner       = "SAP Team"
    }
  }

  os_disk_config = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 128
  }

  data_disks = {
    "data-disk-1" = {
      name                 = "disk-s4app-data-01"
      disk_id              = module.app_data_disk.id
      caching              = "ReadWrite"
      lun                  = 10
      storage_account_type = "Premium_LRS"
      disk_size_gb         = 128
    }
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
```

## Notes
- The VM name must start with `vm-` as enforced by the validation rule.
- This module does not create the subnet or proximity placement group. Use the appropriate modules to create those resources and pass their IDs to this module.
