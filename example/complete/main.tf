locals {
  region      = "East US"
  environment = "prod"
  name        = "aks"
  additional_tags = {
    Owner      = "Organization_name"
    Expires    = "Never"
    Department = "Engineering"
  }
  vnet_address_space     = "20.10.0.0/16"
  pod_cidr_block         = replace(local.vnet_address_space, "10", "244")
  dns_service_ip         = replace(local.vnet_address_space, ".0/16", ".10")
  docker_bridge_cidr     = replace(local.vnet_address_space, "10.0", "10.100")
  subnet_count           = 3
  base_subnet            = replace(local.vnet_address_space, "/16", "/24")
  subnet_prefix          = "subnet"
  subnets                = [for i in range(local.subnet_count) : {
    name                 = "${local.subnet_prefix}-${i + 1}"
    cidr                 = replace(local.base_subnet, ".0.0", ".${i + 1}.0")
  }]
  subnet_cidrs           = [for s in local.subnets : s.cidr]
  subnet_names           = [for s in local.subnets : s.name]
  network_plugin         = "kubenet"
  k8s_version            = "1.26.3"
  vpn_server_enabled     = false
}

resource "azurerm_resource_group" "terraform_infra" {
  name     = format("%s-%s-rg", local.name, local.environment)
  location = local.region
  tags     = local.additional_tags
}

module "network" {
  depends_on          = [azurerm_resource_group.terraform_infra]
  source              = "Azure/network/azurerm"
  version             = "3.3.0"
  resource_group_name = azurerm_resource_group.terraform_infra.name
  vnet_name           = format("%s-%s-network", local.name, local.environment)
  address_space       = local.vnet_address_space
  subnet_prefixes     = local.subnet_cidrs
  subnet_names        = local.subnet_names
  tags = local.additional_tags
}

module "security_groups_subnet_route_table_association" {
  depends_on                 = [module.network]
  source                     = "../../modules/security-groups"
  subnet_prefixes            = local.subnet_cidrs
  subnet_names               = local.subnet_names
  resource_group_name        = azurerm_resource_group.terraform_infra.name
  resource_group_location    = azurerm_resource_group.terraform_infra.location
  vnet_subnets               = module.network.vnet_subnets
}

module "kubenet_dependencies" {
  source     = "../../modules/kubenet_dependencies"

  resource_group_name        = azurerm_resource_group.terraform_infra.name
  resource_group_location    = azurerm_resource_group.terraform_infra.location
  network_plugin             = local.network_plugin
}

module "aks_cluster" {
  depends_on = [module.kubenet_dependencies]
  source     = "../../modules/aks_cluster"

  user_assigned_identity_id         = module.kubenet_dependencies.user_assigned_identity_id
  agents_count                      = "1"
  agents_size                       = "Standard_B2s"
  network_plugin                    = local.network_plugin
  net_profile_dns_service_ip        = local.dns_service_ip
  net_profile_docker_bridge_cidr    = local.docker_bridge_cidr
  net_profile_pod_cidr              = local.pod_cidr_block
  net_profile_service_cidr          = local.vnet_address_space
  agents_pool_name                  = format("%spool", local.name)
  os_disk_size_gb                   = "30"
  enable_auto_scaling               = "true"
  agents_min_count                  = "1"
  agents_max_count                  = "3"
  enable_node_public_ip             = "true"
  agents_availability_zones         = ["1", "2", "3"]
  rbac_enabled                      = "true"
  agents_max_pods                   = "58"
  resource_group_name               = azurerm_resource_group.terraform_infra.name
  resource_group_location           = azurerm_resource_group.terraform_infra.location
  environment                       = local.environment
  name                              = local.name
  kubernetes_version                = local.k8s_version
  private_cluster_enabled           = "false"
  sku_tier                          = "Free"
  enable_http_application_routing   = "false" # The HTTP application routing add-on doesn't work with AKS versions 1.22.6+.
#   subnet_id                         = module.network.subnet_ids
#   admin_username                    = var.admin_username
#   public_ssh_key                    = var.public_ssh_key
#   agents_type                       = var.agents_type
#   net_profile_outbound_type         = var.net_profile_outbound_type
#   enable_kube_dashboard             = var.enable_kube_dashboard
#   balance_similar_node_groups       = var.balance_similar_node_groups
#   max_graceful_termination_sec      = var.max_graceful_termination_sec
#   scale_down_delay_after_add        = var.scale_down_delay_after_add
#   scale_down_delay_after_delete     = var.scale_down_delay_after_delete
#   scale_down_delay_after_failure    = var.scale_down_delay_after_failure
#   scan_interval                     = var.scan_interval
#   scale_down_unneeded               = var.scale_down_unneeded
#   scale_down_unready                = var.scale_down_unready
#   scale_down_utilization_threshold  = var.scale_down_utilization_threshold
#   client_id                         = var.client_id
#   client_secret                     = var.client_secret
}
module "aks_bootstrap" {
  depends_on = [module.aks_cluster]
  source     = "../../modules/aks_bootstrap"

  resource_group_name        = azurerm_resource_group.terraform_infra.name
  cluster_name               = module.aks_cluster.cluster_name
  cert_manager_enabled       = "true"
  cert_manager_version       = "1.12.1"
  ingress_nginx_enabled      = "true"
  ingress_nginx_version      = "4.2.5"
  resource_group_location    = azurerm_resource_group.terraform_infra.location
  network_plugin             = local.network_plugin
}
module "aks_node_pool" {
  depends_on = [module.aks_cluster]
  source     = "../../modules/aks_node_pool"

  node_pool                  = {}
  kubernetes_cluster_id      = module.aks_cluster.kubernetes_cluster_id
  enable_auto_scaling        = "true"
  enable_node_public_ip      = "true"
  kubernetes_version         = local.k8s_version
  # subnet_id                  = module.network.subnet_ids
}