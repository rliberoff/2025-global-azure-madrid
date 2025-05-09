output "kaito_inference_endpoint" {
  description = "The Kaito inference endpoint for the deployed model."
  value       = module.kaito.endpoint
}

output "aks_connection_command" {
  description = "Command to connect to the AKS cluster using Azure CLI."
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.rg.name} --name ${module.aks.name}"
}
