terraform {
  required_version = ">= 1.11.4"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>2.3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.17.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.7.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.36.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~>1.19.0"
    }
  }
}

provider "azapi" {}

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

provider "kubernetes" {
  host                   = module.aks.host
  client_key             = base64decode(module.aks.client_key)
  client_certificate     = base64decode(module.aks.client_certificate)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}

provider "kubectl" {
  host                   = module.aks.host
  client_key             = base64decode(module.aks.client_key)
  client_certificate     = base64decode(module.aks.client_certificate)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks.host
    client_key             = base64decode(module.aks.client_key)
    client_certificate     = base64decode(module.aks.client_certificate)
    cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
  }
}
