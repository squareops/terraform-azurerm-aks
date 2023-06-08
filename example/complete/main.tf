locals {
  region      = "East US"
  environment = "demo"
  name        = "skaf"
  additional_tags = {
    Owner      = "Organization_name"
    Expires    = "Never"
    Department = "Engineering"
  }
  vnet_address_space     = "20.10.0.0/16" # Do not modify last two octets i.e ".0.0/16" 
  subnet_count           = 1
  base_subnet            = replace(local.vnet_address_space, "/16", "/24")
  subnet_prefix          = "subnet"
  subnets                = [for i in range(local.subnet_count) : {
    name                 = "${local.subnet_prefix}-${i + 1}"
    cidr                 = replace(local.base_subnet, ".0.0", ".${i + 1}.0")
  }]
  subnet_cidrs           = [for s in local.subnets : s.cidr]
  subnet_names           = [for s in local.subnets : s.name]
  network_plugin         = "kubenet"  #CNI
  k8s_version            = "1.26.3"
}

resource "azurerm_resource_group" "terraform_infra" {
  name            = format("%s-%s-rg", local.name, local.environment)
  location        = local.region
  tags            = local.additional_tags
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
  tags                = local.additional_tags
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

resource "tls_private_key" "key" {
  algorithm = "RSA"
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
  agents_count                      = "1" # per node pool
  agents_size                       = ["Standard_B2s", "Standard_DS2_v2"]  # node pool vm sizes
  network_plugin                    = local.network_plugin
  net_profile_dns_service_ip        = "192.168.0.10" # IP address within the Kubernetes service address range that will be used by cluster service discovery. Don't use the first IP address in your address range. The first address in your subnet range is used for the kubernetes.default.svc.cluster.local address.
  net_profile_docker_bridge_cidr    = "172.17.0.1/16" # It's required to select a CIDR for the Docker bridge network address because otherwise Docker will pick a subnet automatically, which could conflict with other CIDRs. You must pick an address space that doesn't collide with the rest of the CIDRs on your networks, including the cluster's service CIDR and pod CIDR. Default of 172.17.0.1/16. 
  net_profile_pod_cidr              = "10.244.0.0/16" # for aks pods cidr
  net_profile_service_cidr          = "192.168.0.0/16" # This range shouldn't be used by any network element on or connected to this virtual network. Service address CIDR must be smaller than /12. You can reuse this range across different AKS clusters.
  agents_pool_name                  = [format("%sinfra", local.name), format("%sapp", local.name)]
  os_disk_size_gb                   = "30"
  enable_auto_scaling               = "true"
  agents_min_count                  = "1"
  agents_max_count                  = "3"
  enable_node_public_ip             = "false" # If we want to create public nodes set this value "true"
  agents_availability_zones         = ["1", "2", "3"] # Applies to all the regions except Central India
  rbac_enabled                      = "true"
  agents_max_pods                   = "58"
  resource_group_name               = azurerm_resource_group.terraform_infra.name
  resource_group_location           = azurerm_resource_group.terraform_infra.location
  environment                       = local.environment
  name                              = format("%s-aks", local.name)
  kubernetes_version                = local.k8s_version
  private_cluster_enabled           = "false"  # Cluster endpoint
  sku_tier                          = "Free"
  enable_http_application_routing   = "false" # The HTTP application routing add-on doesn't work with AKS versions 1.22.6+.
  subnet_id                         = module.security_groups_subnet_route_table_association.subnet_id
  admin_username                    = "azureuser"  # node pool username
  public_ssh_key                    = tls_private_key.key.public_key_openssh
  agents_type                       = "VirtualMachineScaleSets"  # Creates an Agent Pool backed by a Virtual Machine Scale Set.
  net_profile_outbound_type         = "loadBalancer"
  enable_kube_dashboard             = "false" # Set "true" when "kubernetes_version" is below 1.19
}

module "aks_node_pool" {
  depends_on = [module.aks_cluster]
  source     = "../../modules/aks_node_pool"

  node_pool                  = {}
  kubernetes_cluster_id      = module.aks_cluster.kubernetes_cluster_id
  enable_auto_scaling        = "true"
  enable_node_public_ip      = "false" # If we want to create public nodes set this value "true"
  kubernetes_version         = local.k8s_version
  subnet_id                  = module.security_groups_subnet_route_table_association.subnet_id
}