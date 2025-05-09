variable "resource_group_id" {
  description = "(Required) Specifies the resource id of the resource group."
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "(Required) Specifies the name of the resource group."
  type        = string
  nullable    = false
}

variable "tenant_id" {
  description = "(Required) The Tenant ID of the System Assigned Identity which is used by master components."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "(Optional) Specifies the tags to associate with related Kaito resources."
  default     = {}
  nullable    = false
}

/* AKS Parameters */

variable "aks_id" {
  description = "(Required) The ID of the AKS cluster."
  type        = string
  nullable    = false
}

variable "aks_name" {
  description = "(Required) The name of the AKS cluster."
  type        = string
  nullable    = false
}

variable "aks_location" {
  description = "(Required) The name of the AKS cluster."
  type        = string
  nullable    = false
}

variable "aks_node_resource_group_name" {
  description = "(Required) The name of the resource group of the AKS cluster node."
  type        = string
  nullable    = false
}

variable "aks_oidc_issuer_url" {
  description = "(Required) The OIDC issuer URL of the AKS cluster."
  type        = string
  nullable    = false
}

/* GPU Provisioner */

variable "gpu_provisioner_version" {
  description = "(Required) Specifies the version of the GPU provisioner. Check current version and more info: https://github.com/Azure/gpu-provisioner/blob/main/charts/gpu-provisioner/README.md"
  type        = string
  nullable    = false
  default     = "0.3.3"
}

/* NSG Paramters */

variable "network_security_group_name" {
  description = "(Required) Specifies the name of the Azure Network Security Group (NSG) to configure with rules for the Ollama service."
  type        = string
  nullable    = false
}

/* Kaito */

variable "kaito_workspace_version" {
  description = "(Required) Specifies the version of the Kaito Workspace. Check current version and more info: https://github.com/kaito-project/kaito/blob/main/README.md"
  type        = string
  nullable    = false
  default     = "0.4.5"
}

variable "kaito_inference_port" {
  description = "(Required) Specifies the port on which the Kaito inference service listens. Defaults to `5000`."
  type        = number
  nullable    = false
  default     = 5000
}

variable "kaito_instance_type_vm_size" {
  description = "(Optional) Specifies the GPU node SKU. This field defaults to `Standard_NC6s_v3` if not specified."
  type        = string
  default     = "Standard_NC24ads_A100_v4"
}

variable "kaito_aks_namespace" {
  description = "(Optional) Specifies the namespace of the workload application that accesses the Azure OpenAI Service. Defaults to `kaito-rag`."
  type        = string
  nullable    = false
  default     = "kaito"
}

variable "kaito_identity_name" {
  description = "(Required) Specifies the object ID of the User Assigned Identity to associate with Kaito."
  type        = string
  nullable    = false
}

variable "kaito_identity_resource_group_name" {
  description = "(Required) Specifies the object ID of the User Assigned Identity to associate with Kaito."
  type        = string
  nullable    = false
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
}

variable "kaito_ai_runtime" {
  description = "(Optional) Specifies the runtime for KAITO, which now supports both `vLLM` and `transformers` runtime. The `vLLM` provides better serving latency and throughput. The `transformers` provides more compatibility with models from Huggingface model hub. More information here: https://github.com/kaito-project/kaito/blob/main/docs/inference/README.md#inference-runtime-selection."
  type        = string
  nullable    = false
  default     = "transformers"

  validation {
    condition     = contains(["transformers", "vllm"], var.kaito_ai_runtime)
    error_message = "The Kaito AI runtime must be one of the following: `transformers` or `vllm`."
  }
}
