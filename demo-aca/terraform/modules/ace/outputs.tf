output "id" {
  description = "Specifies the ID of the Azure Container App Environment."
  value       = azapi_resource.ace.id
}

output "default_domain" {
  description = "Specifies the default, publicly resolvable, name of this Container App Environment."
  value       = azapi_resource.ace.output.properties.defaultDomain
}
