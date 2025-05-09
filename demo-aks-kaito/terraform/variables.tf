## ---- COMMON VARIABLES & RESOURCE GROUP ---- ##

variable "subscription_id" {
  description = "(Required) The Azure subscription ID where resources will be provisioned. This value must be provided and cannot be null."
  type        = string
  nullable    = false
}

variable "use_random_suffix" {
  description = "(Required) If `true`, a random suffix is generated and added to the resource groups and its resources. If `false`, the `suffix` variable is used instead."
  type        = bool
  nullable    = false
  default     = true
}

variable "suffix" {
  description = "(Optional) A suffix for the name of the resource group and its resources. If variable `use_random_suffix` is `true`, this variable is ignored."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.suffix == null || can(regex("^[a-zA-Z0-9]*$", var.suffix))
    error_message = "The suffix can only contain letters (any case) and numbers."
  }
}

variable "location" {
  description = "(Required) Specifies the location for the resource group and most of its resources. Defaults to `westeurope`"
  type        = string
  nullable    = false
  default     = "germanywestcentral"
}

variable "tags" {
  description = "(Optional) Specifies tags for all the resources."
  nullable    = false
  default = {
    createdBy    = "Rodrigo Liberoff"
    createdFor   = "2025 Global Azure Madrid"
    createdUsing = "Terraform"
  }
}

/* RESOURCE GROUP */

variable "resource_group_name" {
  description = "(Required) The name of the resource group."
  type        = string
  nullable    = false
  default     = "rg-global-azure-madrid-2025-aks-kaito"
}

## ---- SPECIFIC RESOURCES & SERVICES ---- ##

/* LOG ANALYTICS WORKSPACE */

variable "log_analytics_workspace_name" {
  description = "(Required) Specifies the name of the Log Analytics Workspace."
  default     = "log-kaito"
  type        = string
  nullable    = false
}

/* APPLICATION INSIHGTS */

variable "appinsights_name" {
  description = "(Required) Specifies the name of the Application Insights."
  type        = string
  nullable    = false
  default     = "appi-kaito"
}

/* VIRTUAL NETWORK */

variable "vnet_address_space" {
  description = "(Required) Specifies the address space (a.k.a. prefix) for the Azure Virtual Network. Defaults to `10.0.0.0/8`."
  type        = list(string)
  nullable    = false
  default     = ["10.0.0.0/8"]
}

variable "vnet_name" {
  description = "(Required) Specifies the name of the Azure Virtual Network (eventually required by an Azure Kubernetes Service)."
  type        = string
  nullable    = false
  default     = "vnet-kaito"
}

/* SUBNET */

variable "subnet_name" {
  description = "(Required) Specifies the name of the Azure Subnet."
  type        = string
  nullable    = false
  default     = "subnet-kaito"
}

variable "subnet_address_space" {
  description = "(Required) The address space that is used the Azure Subnet. Defaults to `10.1.1.0/24`."
  type        = list(string)
  nullable    = false
  default     = ["10.1.1.0/24"]
}

/* NETWORK SECURITY GROUP */

variable "nsg_name" {
  description = "(Required) Specifies the name of the Azure Network Security Group (NSG)."
  type        = string
  nullable    = false
  default     = "nsg-kaito"
}

/* SSH KEY */

variable "ssh_key_name" {
  description = "(Required) Specifies the name of the SSH Key resource. Changing this forces a new resource to be created."
  type        = string
  nullable    = false
  default     = "sshkey-kaito"
}

/* AZURE KUBERNETES SERVICE (AKS) */

variable "aks_name" {
  description = "(Required) Specifies the name of the Azure Kubernetes Service (AKS) cluster."
  type        = string
  nullable    = false
  default     = "aks-kaito"
}

variable "aks_kubernetes_version" {
  description = "(Required) The Kubernetes version for the AKS cluster. Defaults to `1.30.0`. More info: https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?wt.mc_id=MVP_348953"
  type        = string
  nullable    = false
  default     = "1.30"
}

variable "aks_sku" {
  description = "(Optional) The SKU Tier that should be used for this Azure Kubernetes Service (AKS) Cluster. Possible values are `Free`, `Standard`, `Premium` (which includes the Uptime SLA). Defaults to `Standard`."
  type        = string
  nullable    = false
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.aks_sku)
    error_message = "The SKU tier is invalid. Possible values are `Free`, `Standard`. `Premium`."
  }
}

variable "aks_dns_prefix" {
  description = "(Optional) DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created."
  type        = string
  default     = "dns-aks-kaito"
}

variable "aks_admin_username" {
  description = "(Required) Specifies the Admin Username for the Azure Kubernetes Service (AKS) cluster worker nodes. Changing this forces a new resource to be created."
  type        = string
  nullable    = false
  default     = "azureadmin"
}

variable "aks_oms_agent_addon_msi_auth_for_monitoring_enabled" {
  description = "(Optional) Specifies whether to use Managed Service Identity (MSI) authentication for the Operation Management Suite Agent (OMS Agent). Defaults to `true`."
  type        = bool
  nullable    = false
  default     = true
}

variable "aks_system_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within the System Node Pool. Valid values are between 0 and 1000. Defaults to 3."
  type        = number
  nullable    = false
  default     = 3
}

variable "aks_system_node_pool_vm_size" {
  description = "(Required) Specifies the Virtual Machine size (SKU) which should be used for the Virtual Machines used for the System Node Pool. Changing this forces a new resource to be created. Defaults to `Standard_D2s_v5`."
  type        = string
  nullable    = false
  default     = "Standard_D4_v5"
}

/* AZURE PUBLIC IP */

variable "pip_name" {
  description = "(Required) Specifies the name of the Azure Public IP."
  type        = string
  nullable    = false
  default     = "pip-kaito"
}

/* MANAGE IDENTITY */

variable "managed_identity_name" {
  description = "(Required) Specifies the name of the Managed Identity."
  type        = string
  nullable    = false
  default     = "id-kaito"
}

/* KAITO */

variable "kaito_aks_namespace" {
  description = "(Optional) Specifies the namespace of the workload application that accesses the Azure OpenAI Service. Defaults to `kaito-rag`."
  type        = string
  nullable    = false
  default     = "kaito"
}

variable "kaito_instance_type_vm_size" {
  description = "(Optional) Specifies the GPU node SKU. This field defaults to `Standard_NC6s_v3` if not specified."
  type        = string
  default     = "Standard_NC24ads_A100_v4"
}

variable "kaito_service_account_name" {
  description = "(Optional) Specifies the name of the service account of the workload application that accesses the Azure OpenAI Service. Defaults to `kaito-rag-sa`."
  type        = string
  nullable    = false
  default     = "kaito-sa"
}

variable "kaito_ai_model" {
  description = "(Required) Specifies the name of the AI model to deploy with Kaito. Not all models are supported. Please refer to the Kaito documentation for more information here: https://github.com/Azure/kaito/blob/main/presets/README.md"
  type        = string
  nullable    = false
  default     = "Qwen/Qwen2.5-7B-Instruct-1M"
}
