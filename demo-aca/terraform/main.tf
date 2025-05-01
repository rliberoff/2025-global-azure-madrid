data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

resource "random_id" "random" {
  byte_length = 8
}

locals {
  suffix      = lower(trimspace(var.use_random_suffix ? substr(lower(random_id.random.hex), 1, 5) : var.suffix))
  name_suffix = local.suffix != null ? "${local.suffix}" : ""

  name_app_insights            = "${var.app_insights_name}-${local.name_suffix}"
  name_ace                     = "${var.ace_name}-${local.name_suffix}"
  name_log_analytics_workspace = "${var.log_analytics_workspace_name}-${local.name_suffix}"
  name_manage_identity         = "${var.managed_identity_name}-${local.name_suffix}"
  name_resource_group          = "${var.resource_group_name}-${local.name_suffix}"
  name_storage_account         = "${var.storage_account_name}${local.name_suffix}"

  tags = merge(var.tags, {
    createdAt = "${formatdate("YYYY-MM-DD hh:mm:ss", timestamp())} UTC"
    suffix    = local.suffix
  })
}

resource "azurerm_resource_group" "rg" {
  name     = local.name_resource_group
  location = var.location
  tags     = local.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

module "mi" {
  source              = "./modules/mi"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  name                = local.name_manage_identity
  tags                = local.tags
}

module "log" {
  source              = "./modules/log"
  name                = local.name_log_analytics_workspace
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

module "appi" {
  source                     = "./modules/appi"
  name                       = local.name_app_insights
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = module.log.id
  tags                       = local.tags
}

module "st" {
  source                   = "./modules/st"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  name                     = local.name_storage_account
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  identity_id              = module.mi.id
  tags                     = local.tags
}

module "ace" {
  source                                 = "./modules/ace"
  resource_group_name                    = azurerm_resource_group.rg.name
  location                               = var.ace_location == null ? var.location : var.ace_location
  name                                   = local.name_ace
  identity_id                            = module.mi.id
  use_infrastructure_resource_group_name = var.ace_use_infrastructure_resource_group_name
  log_analytics_workspace_id             = module.log.workspace_id
  log_analytics_shared_key               = module.log.primary_shared_key
  mutual_tls_enabled                     = var.ace_mutual_tls_enabled
  workload_profile_name                  = var.ace_workload_profile_name
  workload_profile_type                  = var.ace_workload_profile_type
  tags                                   = local.tags
}

locals {
  aca_common_environmental_variables = [
    {
      name  = "AZURE_CLIENT_ID"
      value = module.mi.client_id
    },
    {
      name  = "AZURE_TENANT_ID"
      value = module.mi.tenant_id
    },
  ]
}

module "aca-ollama" {
  depends_on = [module.st]

  source                                 = "./modules/aca-ollama"
  container_environment_id               = module.ace.id
  resource_group_name                    = azurerm_resource_group.rg.name
  revision_mode                          = var.aca_ollama_revision_mode
  tags                                   = local.tags
  identity_id                            = module.mi.id
  storage_account_name                   = local.name_storage_account
  environmental_variables                = concat(local.aca_common_environmental_variables, var.aca_ollama_environmental_variables)
  ingress_external_enabled               = var.aca_ollama_ingress_external_enabled
  ingress_traffic_weight_latest_revision = var.aca_ollama_ingress_traffic_weight_latest_revision
  ingress_traffic_weight_percentage      = var.aca_ollama_ingress_traffic_weight_percentage
  models                                 = var.aca_ollama_models
}
