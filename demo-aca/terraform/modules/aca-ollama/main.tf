
data "azurerm_storage_account" "storage_account" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_share" "ollama-models-storage" {
  name               = "ollama-models"
  storage_account_id = data.azurerm_storage_account.storage_account.id
  quota              = 50
}

resource "azurerm_container_app_environment_storage" "ollama-models-storage" {
  name                         = "ollama-models"
  container_app_environment_id = var.container_environment_id
  account_name                 = var.storage_account_name
  share_name                   = azurerm_storage_share.ollama-models-storage.name
  access_key                   = data.azurerm_storage_account.storage_account.primary_access_key
  access_mode                  = "ReadWrite"
}

resource "azurerm_container_app" "aca" {
  name                         = "aca-ollama"
  container_app_environment_id = var.container_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode
  tags                         = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  template {
    max_replicas = 1
    min_replicas = 1

    container {
      name   = "ollama"
      image  = "docker.io/ollama/ollama:0.6.6"
      cpu    = "24"
      memory = "220Gi"

      # Add startup command to pull models before launching the server
      command = ["/bin/bash", "-c"]
      args = [
        <<-EOT
        ollama serve & 
        sleep 10
        ${join(" && ", [for model in var.models : "echo 'Pulling ${model}...' && ollama pull ${model}"])}
        wait
        EOT
      ]

      volume_mounts {
        name = azurerm_container_app_environment_storage.ollama-models-storage.name
        path = "/root/.ollama" # Default path where Ollama stores models
      }

      dynamic "env" {
        for_each = var.environmental_variables != null ? var.environmental_variables : []
        content {
          name  = env.value.name
          value = env.value.value
        }
      }

      liveness_probe {
        transport               = "HTTP"
        port                    = 11434
        path                    = "/"
        initial_delay           = 30
        timeout                 = 10
        interval_seconds        = 30
        failure_count_threshold = 3
      }

      # Add startup probe for long-running model pulls, to prevent premature restart during large model downloads.
      startup_probe {
        transport               = "HTTP"
        port                    = 11434
        path                    = "/"
        initial_delay           = 60
        timeout                 = 10
        interval_seconds        = 30
        failure_count_threshold = 20 # Allow enough time for large model downloads
      }
    }

    volume {
      name         = azurerm_storage_share.ollama-models-storage.name
      storage_name = azurerm_container_app_environment_storage.ollama-models-storage.name
      storage_type = "AzureFile"
    }
  }

  workload_profile_name = "GPU-NC24-A100"

  ingress {
    external_enabled = var.ingress_external_enabled
    target_port      = 11434

    traffic_weight {
      latest_revision = var.ingress_traffic_weight_latest_revision
      percentage      = var.ingress_traffic_weight_percentage
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
