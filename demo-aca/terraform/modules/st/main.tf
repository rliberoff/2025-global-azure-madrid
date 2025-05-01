resource "azurerm_storage_account" "sa" {
  resource_group_name             = var.resource_group_name
  location                        = var.location
  name                            = var.name
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  allow_nested_items_to_be_public = false
  tags                            = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
