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

output "nginx_ingress_controller_external_ip" {
  description = "NGINX Ingress Controller External IP"
  value       = "${module.aks_bootstrap.nginx_ingress_controller_external_ip}"
}

# output "kms_tenant_id" {
#   description = "Tenant ID"
#   value       = "${data.azuread_client_config.current.tenant_id}"
# }

# output "kms_object_id" {
#   description = "Object ID"
#   value       = "${data.azuread_client_config.current.object_id}"
# }