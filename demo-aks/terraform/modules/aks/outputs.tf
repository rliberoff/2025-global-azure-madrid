output "client_key" {
  description = "Specifies the client key of the Azure Kubernetes Service (AKS) cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_key
  sensitive   = true
}

output "client_certificate" {
  description = "Specifies the client certificate of the Azure Kubernetes Service (AKS) cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Specifies the cluster certificate authority (CA) of the Azure Kubernetes Service (AKS) cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate
  sensitive   = true
}

output "host" {
  description = "Specifies the host of the Azure Kubernetes Service (AKS) cluster."
  value       = azurerm_kubernetes_cluster.aks.kube_config.0.host
}
