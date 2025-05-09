data "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = var.msi_name
  resource_group_name = var.msi_resource_group_name != null ? var.msi_resource_group_name : var.resource_group_name
}

locals {
  streams = [
    "Microsoft-ContainerLog",
    "Microsoft-ContainerLogV2",
    "Microsoft-KubeEvents",
    "Microsoft-KubePodInventory",
    "Microsoft-KubeNodeInventory",
    "Microsoft-KubePVInventory",
    "Microsoft-KubeServices",
    "Microsoft-KubeMonAgentEvents",
    "Microsoft-InsightsMetrics",
    "Microsoft-ContainerInventory",
    "Microsoft-ContainerNodeInventory",
    "Microsoft-Perf"
  ]
}

resource "azurerm_kubernetes_cluster" "aks" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.name
  sku_tier            = var.sku
  dns_prefix          = var.dns_prefix == null ? "dns-${var.name}" : var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  node_resource_group = "${var.resource_group_name}-generated"

  # Enable worload identity and OpenID Connect issuer to (eventually) enable identity federation 
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Enable application routing add-on, as a managed NGINX ingress controller.
  web_app_routing {
    dns_zone_ids = []
  }

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  network_profile {
    service_cidr        = "172.0.0.0/16"
    dns_service_ip      = "172.0.0.10"
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
  }

  default_node_pool {
    name                        = "system"
    temporary_name_for_rotation = "systemtemp"
    node_count                  = var.system_node_pool_node_count
    vm_size                     = var.system_node_pool_vm_size
    vnet_subnet_id              = var.system_node_pool_vnet_subnet_id
    orchestrator_version        = var.kubernetes_version
    auto_scaling_enabled        = false
    tags                        = var.tags

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.user_assigned_identity.id]
  }

  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = var.msi_auth_for_monitoring_enabled
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool.0.node_count,
      default_node_pool.0.orchestrator_version,
      default_node_pool.0.upgrade_settings,
      default_node_pool.0.tags,
      tags,
    ]
  }
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                = "rule-${var.name}-${var.location}"
  resource_group_name = var.resource_group_name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = "ContainerInsightsWorkspace"
    }
  }

  data_flow {
    streams      = local.streams
    destinations = ["ContainerInsightsWorkspace"]
  }

  data_sources {
    extension {
      streams        = local.streams
      extension_name = "ContainerInsights"
      extension_json = jsonencode({
        "dataCollectionSettings" : {
          "interval" : "1m"
          "namespaceFilteringMode" : "Off",
          "namespaces" : ["kube-system", "gatekeeper-system", "azure-arc"]
          "enableContainerLogV2" : true
        }
      })
      name = "ContainerInsightsExtension"
    }
  }

  description = "Data Collection Rule (DCR) for Azure Monitor Container Insights"
}

resource "azurerm_monitor_data_collection_rule_association" "_" {
  name                    = "ruleassoc-${var.name}-${var.location}"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
  description             = "Association of Container Insights (CI) Data Collection Rule (DCR). Deleting this association will break the data collection for this AKS cluster."
}

resource "azurerm_role_assignment" "network_contributor_role" {
  scope                            = var.resource_group_id
  role_definition_name             = "Network Contributor"
  principal_id                     = data.azurerm_user_assigned_identity.user_assigned_identity.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_monitor_diagnostic_setting" "_" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  enabled_log {
    category = "guard"
  }

  metric {
    category = "AllMetrics"
  }
}
