## ---- COMMON VARIABLES & RESOURCE GROUP ---- ##

variable "subscription_id" {
  description = "(Required) The Azure subscription ID where resources will be provisioned. This value must be provided and cannot be null."
  type        = string
  nullable    = false
}

variable "use_random_suffix" {
  description = "(Required) If `true`, a random suffix is generated and added to the resource groups and its resources. If `false`, the `suffix` variable is used instead. Defaults to `true`."
  type        = bool
  nullable    = false
  default     = true
}

variable "suffix" {
  description = "(Optional) A suffix for the name of the resource group and its resources. If variable `use_random_suffix` is `true`, this variable is ignored. It can only contain letters (any case) and numbers. Defaults to `null`."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.suffix == null || can(regex("^[a-zA-Z0-9]*$", var.suffix))
    error_message = "The suffix can only contain letters (any case) and numbers."
  }
}

variable "location" {
  description = "(Required) Specifies the location for the resource group and most of its resources. Defaults to `swedencentral`"
  type        = string
  nullable    = false
  default     = "swedencentral"
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
  default     = "rg-global-azure-madrid-2025-aca"
}

## ---- SPECIFIC RESOURCES & SERVICES ---- ##

/* APPLICATION INSIHGTS */

variable "app_insights_name" {
  description = "(Required) Specifies the name of the Application Insights."
  type        = string
  nullable    = false
  default     = "appi-ollama"
}

/* LOG ANALYTICS WORKSPACE */

variable "log_analytics_workspace_name" {
  description = "(Required) Specifies the name of the Log Analytics Workspace."
  type        = string
  nullable    = false
  default     = "log-ollama"
}

/* CONTAINER ENVIRONMENT */

variable "ace_location" {
  description = "(Optional) Specifies the location of the Azure Container Environment (ACE). If `null`, then the location of the resource group is used. Defaults to `null`."
  type        = string
  nullable    = true
  default     = null
}

variable "ace_name" {
  description = "(Required) Specifies the name of the Azure Container Environment (ACE)."
  type        = string
  nullable    = false
  default     = "ace-ollama"
}

variable "ace_use_infrastructure_resource_group_name" {
  description = "(Optional) Specifies whether to use a platform-managed resource group created for the Managed Environment to host infrastructure resources. Defaults to `false`."
  type        = string
  nullable    = false
  default     = false
}

variable "ace_mutual_tls_enabled" {
  description = "(Optional) Specifies whether mutual TLS is enabled for this Container App Environment. Defaults to `false`."
  type        = bool
  nullable    = false
  default     = false
}

variable "ace_workload_profile_name" {
  description = "(Optional) Specifies the name of the workload profile. This value must be `Consumption` when the variable `workload_profile_type` value is `Consumption`. Defaults to `null`. If this value is set, the `workload_profile_type` value must also be set. When `null` the Azure Container Environment (ACE) will use `Consumption Only`."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.ace_workload_profile_name != "Consumption" || var.ace_workload_profile_type == "Consumption"
    error_message = "The workload profile name must be `Consumption` when the workload profile type is `Consumption`."
  }
}

variable "ace_workload_profile_type" {
  description = "(Optional) Workload profile type for the workloads to run on. Possible values include `Consumption`, `D4`, `D8`, `D16`, `D32`, `E4`, `E8`, `E16` and `E32`. Defaults to `null`. If this value is set, the `workload_profile_name` value must also be set. When `null` the Azure Container Environment (ACE) will use `Consumption Only`."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.ace_workload_profile_type == null || can(index(["Consumption", "D4", "D8", "D16", "D32", "E4", "E8", "E16", "E32"], var.ace_workload_profile_type))
    error_message = "Invalid workload profile type. Possible values include `Consumption`, `D4`, `D8`, `D16`, `D32`, `E4`, `E8`, `E16` and `E32`."
  }
}

/* MANAGE IDENTITY */

variable "managed_identity_name" {
  description = "(Required) Specifies the name of the Managed Identity."
  type        = string
  nullable    = false
  default     = "id-ollama"
}

/* STORAGE ACCOUNT */

variable "storage_account_name" {
  description = "(Required) Specifies the name of the Azure Virtual Network."
  type        = string
  nullable    = false
  default     = "stollama"
}

variable "storage_account_tier" {
  description = "(Required) Defines the Tier to use for this storage account. Valid options are `Standard` and `Premium`. Changing this forces a new resource to be created. Defaults to `Standard`."
  type        = string
  nullable    = false
  default     = "Standard"

  validation {
    condition     = can(regex("^(Standard|Premium)$", var.storage_account_tier))
    error_message = "Invalid account_tier. Valid options are `Standard` and `Premium`."
  }
}

variable "storage_account_replication_type" {
  description = "(Required) Defines the type of replication to use for this storage account. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`. Changing this forces a new resource to be created when types `LRS`, `GRS` and `RAGRS` are changed to `ZRS`, `GZRS` or `RAGZRS` and vice versa. Defaults to `LRS`."
  type        = string
  nullable    = false
  default     = "LRS"

  validation {
    condition     = can(regex("^(LRS|GRS|RAGRS|ZRS|GZRS|RAGZRS)$", var.storage_account_replication_type))
    error_message = "Invalid account_replication_type. Valid options are `LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS` and `RAGZRS`."
  }
}

# OLLAMA #

variable "aca_ollama_environmental_variables" {
  description = "(Optional) Specifies environmental variables for the Ollama container."
  nullable    = false
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "aca_ollama_revision_mode" {
  description = "(Required) The revision mode for the Ollama container. The revisions operational mode for the Azure Container Application. Possible values are `Single` and `Multiple`. Defaults to `Single`."
  type        = string
  nullable    = false
  default     = "Single"
}

variable "aca_ollama_ingress_external_enabled" {
  description = "(Optional) Specifies wheter connections from outside the Ollama Container are enabled or not. Defaults to `true`."
  type        = bool
  nullable    = false
  default     = true
}

variable "aca_ollama_ingress_traffic_weight_latest_revision" {
  description = "(Optional) This traffic Weight applies to the latest stable Ollama container revision. Defaults to `true`."
  type        = bool
  nullable    = false
  default     = true
}

variable "aca_ollama_ingress_traffic_weight_percentage" {
  description = "(Required) The percentage of traffic which should be sent to this Ollama container revision. Defaults to `100`."
  type        = number
  nullable    = false
  default     = 100

  validation {
    condition     = can(regex("^(100|[1-9]?[0-9])$", var.aca_ollama_ingress_traffic_weight_percentage))
    error_message = "The percentage must be between 0 and 100."
  }
}

variable "aca_ollama_models" {
  description = "(Required) List of Ollama models to pull during container initialization."
  type        = list(string)
  nullable    = false
  default     = ["granite3.2-vision:2b-fp16"]
}
