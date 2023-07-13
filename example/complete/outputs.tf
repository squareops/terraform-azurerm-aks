output "name" {
  description = "Common Name"
  value       = local.name
}

output "environment" {
  description = "Environment Name"
  value       = local.environment
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = module.aks_cluster.cluster_name
}

output "default_ng_rg_name" {
  description = "Default Node Group Resource Group Name"
  value       = module.aks_cluster.default_ng_rg_name
}

output "resource_group_name" {
  description = "Resource Group Name"
  value       = azurerm_resource_group.terraform_infra.name
}
output "resource_group_location" {
  description = "Resource Group Name Location"
  value       = azurerm_resource_group.terraform_infra.location
}

output "vnet_id" {
  description = "ID of the Vnet"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "The Name of the newly created vNet"
  value       = module.vnet.vnet_name
}

output "vnet_subnets_name_id" {
  description = "Can be queried subnet-id by subnet name by using lookup(module.vnet.vnet_subnets_name_id, subnet1)"
  value       = module.vnet.vnet_subnets_name_id
}

output "user_assigned_identity_id" {
  description = "user assigned identity ID for CNI"
  value       = azurerm_user_assigned_identity.identity.id
}