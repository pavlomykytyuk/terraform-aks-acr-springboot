terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.93.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraformstorage"
    storage_account_name = "gen1terraformstt"
    container_name       = "gen1terraformcontainer"
    key                  = "gen1tf.tfstate"
    access_key           = ""
  }
}

provider "azurerm" {
  features {}
}