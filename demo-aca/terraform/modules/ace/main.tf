data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# We use the `azapi` provider to create the Azure Container App Environment (ACE) resource
# because GPU-based workload profiles are not supported (yet) in the `azurerm` provider.
resource "azapi_resource" "ace" {
  type      = "Microsoft.App/managedEnvironments@2024-10-02-preview"
  name      = var.name
  parent_id = data.azurerm_resource_group.rg.id
  location  = var.location
  tags      = var.tags
  body = {
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = var.log_analytics_workspace_id
          sharedKey  = var.log_analytics_shared_key
        }
      }

      infrastructureResourceGroup = var.use_infrastructure_resource_group_name ? "${var.resource_group_name}-ace" : null
      peerAuthentication = {
        mtls = {
          enabled = var.mutual_tls_enabled
        }
      }
      workloadProfiles = [
        {
          name                = "Consumption",
          workloadProfileType = "Consumption"
        },
        {
          name                = "GPU-NC24-A100",
          workloadProfileType = "Consumption-GPU-NC24-A100"
        }
      ]
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.identity_id
    ]
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}


