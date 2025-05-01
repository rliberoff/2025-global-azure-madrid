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
  default     = "rg-global-azure-madrid-2025-aks"
}

## ---- SPECIFIC RESOURCES & SERVICES ---- ##

/* LOG ANALYTICS WORKSPACE */

variable "log_analytics_workspace_name" {
  description = "(Required) Specifies the name of the Log Analytics Workspace."
  default     = "log-ollama"
  type        = string
  nullable    = false
}

/* APPLICATION INSIHGTS */

variable "appinsights_name" {
  description = "(Required) Specifies the name of the Application Insights."
  type        = string
  nullable    = false
  default     = "appi-ollama"
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
  default     = "vnet-ollama"
}

/* SUBNET */

variable "subnet_name" {
  description = "(Required) Specifies the name of the Azure Subnet."
  type        = string
  nullable    = false
  default     = "subnet-ollama"
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
  default     = "nsg-ollama"
}

/* SSH KEY */

variable "ssh_key_name" {
  description = "(Required) Specifies the name of the SSH Key resource. Changing this forces a new resource to be created."
  type        = string
  nullable    = false
  default     = "sshkey-ollama"
}

/* AZURE KUBERNETES SERVICE (AKS) */

variable "aks_name" {
  description = "(Required) Specifies the name of the Azure Kubernetes Service (AKS) cluster."
  type        = string
  nullable    = false
  default     = "aks-ollama"
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
  default     = "dns-aks-ollama"
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
  description = "(Optional) The initial number of nodes which should exist within the System Node Pool. Valid values are between 0 and 1000. Defaults to 1."
  type        = number
  nullable    = false
  default     = 1
}

variable "aks_system_node_pool_vm_size" {
  description = "(Required) Specifies the Virtual Machine size (SKU) which should be used for the Virtual Machines used for the System Node Pool. Changing this forces a new resource to be created. Defaults to `Standard_D2s_v5`."
  type        = string
  nullable    = false
  default     = "Standard_D2s_v5"
}

variable "aks_system_node_pool_vnet_subnet_id" {
  description = "(Optional) The ID of a Subnet where the Kubernetes System Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "aks_gpu_node_pool_vm_size" {
  description = "(Required) Specifies the Virtual Machine size (SKU) which should be used for the Virtual Machines used for the GPU Node Pool. It is very important to choose a VM from the families that provides GPUs, like the `NCs v3` Changing this forces a new resource to be created. Defaults to `Standard_NC6s_v3`."
  type        = string
  nullable    = false
  default     = "Standard_NC24ads_A100_v4"
}

variable "aks_gpu_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within the GPU Node Pool. Valid values are between 0 and 1000. Defaults to 1."
  type        = number
  nullable    = false
  default     = 1
}

variable "aks_gpu_node_pool_vnet_subnet_id" {
  description = "(Optional) The ID of a Subnet where the Kubernetes GPU Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

/* AZURE PUBLIC IP */

variable "pip_name" {
  description = "(Required) Specifies the name of the Azure Public IP."
  type        = string
  nullable    = false
  default     = "pip-ollama"
}

/* NVIDIA DEVICE PLUGIN */

variable "nvidia_device_plugin_name" {
  description = "(Required) Specifies the name of the NVIDIA Device Plugin."
  type        = string
  nullable    = false
  default     = "nvidia-device-plugin"
}

variable "nvidia_device_plugin_image_tag" {
  description = "(Required) The image tag for the NVIDIA Device Plugin. Defaults to `v0.16.2`. More info: https://github.com/NVIDIA/k8s-device-plugin"
  type        = string
  nullable    = false
  default     = "v0.17.1"
}

variable "nvidia_device_plugin_chart_version" {
  description = "(Required) The Helm chart version for the NVIDIA Device Plugin. Defaults to `0.16.2`. More info: https://github.com/NVIDIA/k8s-device-plugin"
  type        = string
  nullable    = false
  default     = "v0.17.1"
}

/* OLLAMA */

variable "ollama_name" {
  description = "(Required) Specifies the name of the Ollama service."
  type        = string
  nullable    = false
  default     = "ollama"
}

variable "ollama_port" {
  description = "(Required) The port where the Ollama service will be exposed. Defaults to `11434`."
  type        = number
  nullable    = false
  default     = 11434
}

variable "ollama_image_tag" {
  description = "(Required) The Docker image tag for the Ollama service. Defaults to `0.3.5`. More info: https://hub.docker.com/r/ollama/ollama/tags"
  type        = string
  nullable    = false
  default     = "0.6.5"
}

variable "ollama_chart_version" {
  description = "(Required) The community Helm Chart version for the Ollama service. Defaults to `0.3.5`. More info: https://github.com/otwld/ollama-helm"
  type        = string
  nullable    = false
  default     = "1.14.0"
}

variable "ollama_model_name" {
  description = "(Required) The name of the model that the Ollama service will use. Defaults to `phi3:mini`. More info: https://ollama.com/library"
  type        = string
  nullable    = false
  default     = "granite3.2-vision:2b-fp16"
}
