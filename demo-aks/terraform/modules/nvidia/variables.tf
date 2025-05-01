variable "name" {
  description = "(Required) Specifies the name of the NVIDIA Device Plugin."
  type        = string
  nullable    = false
}

variable "image_tag" {
  description = "(Required) The image tag for the NVIDIA Device Plugin. Defaults to `v0.16.2`. More info: https://github.com/NVIDIA/k8s-device-plugin"
  type        = string
  nullable    = false
  default     = "v0.16.2"
}

variable "chart_version" {
  description = "(Required) The Helm chart version for the NVIDIA Device Plugin. Defaults to `0.16.2`. More info: https://github.com/NVIDIA/k8s-device-plugin"
  type        = string
  nullable    = false
  default     = "v0.16.2"
}

variable "namespace" {
  description = "(Required) Specifies the namespace in Azure Kubernetes Service (AKS) where the NVIDIA Device Plugin will be deployed."
  type        = string
  nullable    = false
}
