resource "azurerm_network_security_rule" "ollama_network_security_rule" {
  name                        = "rule-${var.name}-${var.port}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.port
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

resource "helm_release" "ollama" {
  name             = var.name
  repository       = "https://otwld.github.io/ollama-helm/"
  chart            = "ollama"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  values = [
    "${templatefile("${path.module}/ollama-values.tftpl", {
      tag            = var.image_tag
      port           = var.port
      resource_group = var.resource_group_name
      ip_address     = var.public_ip_address
      model          = var.model_name
      dns_label_name = lower("${var.name}")
    })}"
  ]

  depends_on = [azurerm_network_security_rule.ollama_network_security_rule]
}
