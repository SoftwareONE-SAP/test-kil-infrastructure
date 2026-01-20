terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate-prod-weu"
    storage_account_name = "sttfstateprodweu"
    container_name       = "tfstate"
    key                  = "prod-weu-sap.tfstate"
  }
}

provider "azurerm" {
  features {}
}
