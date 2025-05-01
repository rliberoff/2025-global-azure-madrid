data "azurerm_client_config" "current" {}

resource "random_id" "random" {
  byte_length = 8
}

locals {
  suffix      = lower(trimspace(var.use_random_suffix ? substr(lower(random_id.random.hex), 1, 5) : var.suffix))
  name_suffix = local.suffix != null ? "${local.suffix}" : ""

  aks_name                     = "${var.aks_name}-${local.name_suffix}"
  appinsights_name             = "${var.appinsights_name}-${local.name_suffix}"
  log_analytics_workspace_name = "${var.log_analytics_workspace_name}-${local.name_suffix}"
  nsg_name                     = "${var.nsg_name}-${local.name_suffix}"
  nvidia_device_plugin_name    = "${var.nvidia_device_plugin_name}-${local.name_suffix}"
  ollama_service_name          = "ollama-${local.name_suffix}"
  pip_name                     = "${var.pip_name}-${local.name_suffix}"
  resource_group_name          = "${var.resource_group_name}-${local.name_suffix}"
  ssk_key_name                 = "${var.ssh_key_name}-${local.name_suffix}"
  subnet_name                  = "${var.subnet_name}-${local.name_suffix}"
  vnet_name                    = "${var.vnet_name}-${local.name_suffix}"

  tags = merge(var.tags, {
    createdAt = "${formatdate("YYYY-MM-DD hh:mm:ss", timestamp())} UTC"
    suffix    = local.suffix
  })
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

module "log_analytics_workspace" {
  source              = "./modules/log"
  name                = local.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags
}

module "application_insights" {
  source                     = "./modules/appi"
  name                       = local.appinsights_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = local.tags
}

module "network" {
  source                     = "./modules/network"
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  vnet_name                  = local.vnet_name
  vnet_address_space         = var.vnet_address_space
  subnet_name                = local.subnet_name
  subnet_address_space       = var.subnet_address_space
  nsg_name                   = local.nsg_name
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = local.tags
}

module "public_ip" {
  source              = "./modules/pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  name                = local.pip_name
  tags                = local.tags
}

module "ssh" {
  source              = "./modules/ssh"
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_id   = azurerm_resource_group.rg.id
  location            = var.location
  name                = local.ssk_key_name
  tags                = local.tags
}

module "aks" {
  source                          = "./modules/aks"
  resource_group_id               = azurerm_resource_group.rg.id
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = var.location
  name                            = local.aks_name
  ssh_public_key                  = module.ssh.public_key
  sku                             = var.aks_sku
  dns_prefix                      = lower(var.aks_dns_prefix)
  kubernetes_version              = var.aks_kubernetes_version
  admin_username                  = var.aks_admin_username
  log_analytics_workspace_id      = module.log_analytics_workspace.id
  msi_auth_for_monitoring_enabled = var.aks_oms_agent_addon_msi_auth_for_monitoring_enabled
  system_node_pool_node_count     = var.aks_system_node_pool_node_count
  system_node_pool_vm_size        = var.aks_system_node_pool_vm_size
  system_node_pool_vnet_subnet_id = module.network.subnet_id
  gpu_node_pool_node_count        = var.aks_gpu_node_pool_node_count
  gpu_node_pool_vm_size           = var.aks_gpu_node_pool_vm_size
  gpu_node_pool_vnet_subnet_id    = module.network.subnet_id
  tags                            = local.tags
}

module "nvidia" {
  source        = "./modules/nvidia"
  name          = local.nvidia_device_plugin_name
  chart_version = var.nvidia_device_plugin_chart_version
  image_tag     = var.nvidia_device_plugin_image_tag
  namespace     = local.ollama_service_name

  depends_on = [module.aks]
}

module "ollama" {
  source                      = "./modules/ollama"
  name                        = local.ollama_service_name
  chart_version               = var.ollama_chart_version
  image_tag                   = var.ollama_image_tag
  port                        = var.ollama_port
  public_ip_address           = module.public_ip.public_ip_address
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = module.network.nsg_name
  namespace                   = local.ollama_service_name
  model_name                  = var.ollama_model_name

  depends_on = [module.nvidia]
}
