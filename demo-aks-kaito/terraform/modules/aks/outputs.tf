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

output "node_resource_group" {
  value       = azurerm_kubernetes_cluster.aks.node_resource_group
  description = "Specifies the resource id of the auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
}

output "oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  description = "Specifies the URL of the OpenID Connect issuer used by this Kubernetes Cluster."
}

output "name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "Specifies the name of the Azure Kubernetes Service (AKS) cluster."
}

output "id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "Specifies the ID of the Azure Kubernetes Service (AKS) cluster."
}

output "location" {
  value       = azurerm_kubernetes_cluster.aks.location
  description = "Specifies the location of the AKS cluster."
}
