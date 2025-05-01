terraform {
  required_version = ">= 1.11.4"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>2.3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.27.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.7.1"
    }
  }
}

provider "azapi" {}

provider "azuread" {}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    log_analytics_workspace {
      permanently_delete_on_destroy = true
    }
    resource_group {
      # This flag is set to mitigate an open bug in Terraform.
      # For instance, the Resource Group is not deleted when a `Failure Anomalies` resource is present.
      # As soon as this is fixed, we should remove this.
      # Reference: https://github.com/hashicorp/terraform-provider-azurerm/issues/18026
      prevent_deletion_if_contains_resources = false
    }
  }
}
