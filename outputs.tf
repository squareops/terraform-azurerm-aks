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
  value       = "${module.aks_cluster.cluster_name}"
}

output "default_ng_rg_name" {
  description = "Default Node Group Resource Group Name"
  value       = "${module.aks_cluster.default_ng_rg_name}"
}
