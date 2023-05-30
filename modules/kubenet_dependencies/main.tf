resource "azurerm_user_assigned_identity" "example" {
  count = var.network_plugin == "kubenet" ? 1 : 0
  name                = "aksidentity"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
}
data "azurerm_subscription" "primary" {
  count = var.network_plugin == "kubenet" ? 1 : 0
}
resource "azurerm_role_assignment" "network_contributor" {
  count = var.network_plugin == "kubenet" ? 1 : 0
  scope                = data.azurerm_subscription.primary[0].id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.example[0].principal_id
}
output "user_assigned_identity_id" {
  description = "user_assigned_identity_id"
  value       = var.network_plugin == "kubenet" ? azurerm_user_assigned_identity.example[0].id : null
}