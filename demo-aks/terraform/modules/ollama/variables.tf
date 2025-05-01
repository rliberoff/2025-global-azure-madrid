variable "resource_group_name" {
  description = "(Required) Specifies the name of the resource group."
  type        = string
  nullable    = false
}

variable "name" {
  description = "(Required) Specifies the name of the Ollama service."
  type        = string
  nullable    = false
}

variable "chart_version" {
  description = "(Required) The community Helm Chart version for the Ollama service. Defaults to `0.52.0`. More info: https://github.com/otwld/ollama-helm"
  type        = string
  nullable    = false
  default     = "1.14.0"
}

variable "image_tag" {
  description = "(Required) The Docker image tag for the Ollama service. Defaults to `0.3.5`. More info: https://hub.docker.com/r/ollama/ollama/tags"
  type        = string
  nullable    = false
  default     = "0.6.5"
}

variable "port" {
  description = "(Required) The port where the Ollama service will be exposed. Defaults to `11434`."
  type        = number
  nullable    = false
  default     = 11434
}

variable "public_ip_address" {
  description = "(Required) The public IP address for the Ollama service."
  type        = string
  nullable    = false
}

variable "network_security_group_name" {
  description = "(Required) Specifies the name of the Azure Network Security Group (NSG) to configure with rules for the Ollama service."
  type        = string
  nullable    = false
}

variable "namespace" {
  description = "(Required) Specifies the namespace in Azure Kubernetes Service (AKS) where the Ollama service will be deployed."
  type        = string
  nullable    = false
}

variable "model_name" {
  description = "(Required) The name of the model that the Ollama service will use. More info: https://ollama.com/library"
  type        = string
  nullable    = false
}
