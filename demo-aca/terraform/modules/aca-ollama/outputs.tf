output "application_url" {
  description = "The URL of the Azure Container Application."
  value       = azurerm_container_app.aca.ingress[0].fqdn
  sensitive   = true
}
