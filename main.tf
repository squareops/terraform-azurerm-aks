
module "kubenet_dependencies" {
  source     = "./kubenet_dependencies"

  resource_group_name        = var.resource_group_name
  resource_group_location    = var.resource_group_location
  network_plugin             = var.network_plugin
}
module "aks_cluster" {
  depends_on = [module.kubenet_dependencies]
  source     = "./aks_cluster"

  user_assigned_identity_id         = module.kubenet_dependencies.user_assigned_identity_id
  agents_count                      = var.agents_count
  agents_size                       = var.agents_size
  network_plugin                    = var.network_plugin
  net_profile_dns_service_ip        = var.net_profile_dns_service_ip
  net_profile_docker_bridge_cidr    = var.net_profile_docker_bridge_cidr
  net_profile_outbound_type         = var.net_profile_outbound_type
  net_profile_pod_cidr              = var.net_profile_pod_cidr
  net_profile_service_cidr          = var.net_profile_service_cidr
  agents_pool_name                  = var.agents_pool_name
  os_disk_size_gb                   = var.os_disk_size_gb
  subnet_id                         = var.subnet_id == null ? data.terraform_remote_state.security_groups_subnet_route_table_association.outputs.subnet_id : var.subnet_id
  enable_auto_scaling               = var.enable_auto_scaling
  agents_min_count                  = var.agents_min_count
  agents_max_count                  = var.agents_max_count
  enable_node_public_ip             = var.enable_node_public_ip
  agents_availability_zones         = var.agents_availability_zones
  admin_username                    = var.admin_username
  public_ssh_key                    = var.public_ssh_key
  rbac_enabled                      = var.rbac_enabled
  agents_type                       = var.agents_type
  agents_max_pods                   = var.agents_max_pods
  resource_group_name               = var.resource_group_name
  resource_group_location           = var.resource_group_location
  environment                       = var.environment
  name                              = var.name
  kubernetes_version                = var.kubernetes_version
  private_cluster_enabled           = var.private_cluster_enabled
  sku_tier                          = var.sku_tier
  enable_http_application_routing   = var.enable_http_application_routing
  enable_kube_dashboard             = var.enable_kube_dashboard
  balance_similar_node_groups       = var.balance_similar_node_groups
  max_graceful_termination_sec      = var.max_graceful_termination_sec
  scale_down_delay_after_add        = var.scale_down_delay_after_add
  scale_down_delay_after_delete     = var.scale_down_delay_after_delete
  scale_down_delay_after_failure    = var.scale_down_delay_after_failure
  scan_interval                     = var.scan_interval
  scale_down_unneeded               = var.scale_down_unneeded
  scale_down_unready                = var.scale_down_unready
  scale_down_utilization_threshold  = var.scale_down_utilization_threshold
  client_id                         = var.client_id
  client_secret                     = var.client_secret
}
module "aks_bootstrap" {
  depends_on = [module.aks_cluster]
  source     = "./aks_bootstrap"

  resource_group_name        = var.resource_group_name
  cluster_name               = module.aks_cluster.cluster_name
  cert_manager_enabled       = var.cert_manager_enabled
  cert_manager_version       = var.cert_manager_version
  ingress_nginx_enabled      = var.ingress_nginx_enabled
  ingress_nginx_version      = var.ingress_nginx_version
  resource_group_location    = var.resource_group_location
  network_plugin             = var.network_plugin
}
module "aks_node_pool" {
  depends_on = [module.aks_cluster]
  source     = "./aks_node_pool"

  node_pool                  = var.node_pool
  kubernetes_cluster_id      = module.aks_cluster.kubernetes_cluster_id
  enable_auto_scaling        = var.enable_auto_scaling
  enable_node_public_ip      = var.enable_node_public_ip
  kubernetes_version         = var.kubernetes_version
  subnet_id                  = var.subnet_id == null ? data.terraform_remote_state.security_groups_subnet_route_table_association.outputs.subnet_id : var.subnet_id
}