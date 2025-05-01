variable "resource_group_name" {
  description = "(Required) Specifies the name of the resource group for the Azure Container Application."
  type        = string
  nullable    = false
}

variable "container_environment_id" {
  description = "(Required) The ID of the Container App Environment within which this Container App should exist. Changing this forces a new resource to be created."
  type        = string
  nullable    = false
}

variable "revision_mode" {
  description = "(Required) The revisions operational mode for the Azure Container Application. Possible values are `Single` and `Multiple`. Defaults to `Single`."
  type        = string
  nullable    = false
  default     = "Single"
}

variable "tags" {
  description = "(Optional) Specifies the tags for this resource."
  type        = map(any)
  default     = {}
}

variable "identity_id" {
  description = "(Required) Specifies a the ID of a User Assigned Managed Identities to be associated with this resource."
  type        = string
  nullable    = false
}

variable "ingress_external_enabled" {
  description = "(Optional) Specifies wheter connections from outside the Container App Environment are enabled or not. Defaults to `true`."
  type        = bool
  nullable    = false
  default     = true
}

variable "ingress_traffic_weight_latest_revision" {
  description = "(Optional) This traffic Weight applies to the latest stable Container Revision. Defaults to `true`."
  type        = bool
  nullable    = false
  default     = true
}

variable "ingress_traffic_weight_percentage" {
  description = "(Required) The percentage of traffic which should be sent this revision. Defaults to `100`."
  type        = number
  nullable    = false
  default     = 100

  validation {
    condition     = can(regex("^(100|[1-9]?[0-9])$", var.ingress_traffic_weight_percentage))
    error_message = "The percentage must be between 0 and 100."
  }
}

variable "environmental_variables" {
  description = "(Optional) Specifies environmental variables for the container."
  nullable    = false
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "storage_account_name" {
  description = "(Required) The ID of the storage account to be used for the volume."
  type        = string
  nullable    = false
}

variable "models" {
  description = "(Required) List of Ollama models to pull during container initialization."
  type        = list(string)
  nullable    = false
}
