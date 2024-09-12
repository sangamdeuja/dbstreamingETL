terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.0.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.51.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.2.3"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
provider "databricks" {
  # Configuration options
}

provider "azuread" {
  # Configuration options
}
provider "github" {
  # Configuration options
}
