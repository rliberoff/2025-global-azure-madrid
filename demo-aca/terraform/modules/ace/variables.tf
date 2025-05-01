variable "resource_group_name" {
  description = "(Required) Specifies the name of the resource group for the Azure Container Environment (ACE)."
  type        = string
  nullable    = false
}

variable "location" {
  description = "(Required) Specifies the location of the Azure Container Environment (ACE)."
  type        = string
  nullable    = false
}

variable "identity_id" {
  description = "(Required) Specifies a the ID of a User Assigned Managed Identities to be associated with this resource."
  type        = string
  nullable    = false
}

variable "name" {
  description = "(Required) Specifies the name of the Azure Container Environment (ACE)."
  type        = string
  nullable    = false
}

variable "use_infrastructure_resource_group_name" {
  description = "(Optional) Specifies whether to use a platform-managed resource group created for the Managed Environment to host infrastructure resources. Defaults to `false`."
  type        = string
  nullable    = false
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "(Required) Specifies the resource ID of the Azure Log Analytics Workspace."
  type        = string
  nullable    = false
}

variable "log_analytics_shared_key" {
  description = "(Required) Specifies the workspace shared key of the Azure Log Analytics Workspace."
  type        = string
  nullable    = false
}

variable "mutual_tls_enabled" {
  description = "(Optional) Specifies whether mutual TLS is enabled for this Container App Environment. Defaults to `false`."
  type        = bool
  nullable    = false
  default     = false
}

variable "workload_profile_name" {
  description = "(Optional) Specifies the name of the workload profile. This value must be `Consumption` when the variable `workload_profile_type` value is `Consumption`. Defaults to `null`. If this value is set, the `workload_profile_type` value must also be set. When `null` the Azure Container Environment (ACE) will use `Consumption Only`."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.workload_profile_name != "Consumption" || var.workload_profile_type == "Consumption"
    error_message = "The workload profile name must be `Consumption` when the workload profile type is `Consumption`."
  }
}

variable "workload_profile_type" {
  description = "(Optional) Workload profile type for the workloads to run on. Possible values include `Consumption`, `D4`, `D8`, `D16`, `D32`, `E4`, `E8`, `E16` and `E32`. Defaults to `null`. If this value is set, the `workload_profile_name` value must also be set. When `null` the Azure Container Environment (ACE) will use `Consumption Only`."
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.workload_profile_type == null || can(index(["Consumption", "D4", "D8", "D16", "D32", "E4", "E8", "E16", "E32"], var.workload_profile_type))
    error_message = "Invalid workload profile type. Possible values include `Consumption`, `D4`, `D8`, `D16`, `D32`, `E4`, `E8`, `E16` and `E32`."
  }
}

variable "tags" {
  description = "(Optional) Specifies the tags for this resource."
  type        = map(any)
  default     = {}
}
