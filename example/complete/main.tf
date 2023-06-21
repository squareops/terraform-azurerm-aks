locals {
  region      = "East US"
  environment = "demo"
  name        = "skaf"
  additional_tags = {
    Owner      = "Organization_name"
    Expires    = "Never"
    Department = "Engineering"
  }
  address_space          = "20.10.0.0/16"
  network_plugin         = "kubenet"    # You can choose "kubenet(basic)" or "azure(advanced)" refer https://learn.microsoft.com/en-us/azure/aks/concepts-network#kubenet-basic-networking 
  k8s_version            = "1.26.3"     # Kubernetes cluster version
}

resource "azurerm_resource_group" "terraform_infra" {
  name            = format("%s-%s-rg", local.environment, local.name)
  location        = local.region
  tags            = local.additional_tags
}

module "vnet" {
  depends_on                    = [azurerm_resource_group.terraform_infra]
  source                        = "../../modules/vnet"
  name                          = local.name
  address_space                 = local.address_space
  environment                   = local.environment
  zones                         = 2
  create_public_subnets         = true
  create_private_subnets        = true
  create_database_subnets       = false
  create_resource_group         = false
  existing_resource_group_name  = azurerm_resource_group.terraform_infra.name
  resource_group_location       = local.region
  create_vpn                    = false
  create_nat_gateway            = true
  enable_logging                = false
  additional_tags               = local.additional_tags
}

# SSH private key for aks node pools. Internally managed by terraform.
resource "tls_private_key" "key" {
  algorithm = "RSA"
}

# There are two types of managed idetities "System assigned" & "UserAssigned". User-assigned managed identities can be used on multiple resources.
resource "azurerm_user_assigned_identity" "identity" {
  name                = "aksidentity"
  resource_group_name = azurerm_resource_group.terraform_infra.name
  location            = azurerm_resource_group.terraform_infra.location
}

module "aks_cluster" {
 depends_on = [module.vnet, azurerm_user_assigned_identity.identity]
  source     = "../../"

  user_assigned_identity_id         = azurerm_user_assigned_identity.identity.id
  principal_id                      = azurerm_user_assigned_identity.identity.principal_id
  agents_count                      = "1" # per node pool
  agents_size                       = ["Standard_B2s", "Standard_DS2_v2"]  # node pool vm sizes
  network_plugin                    = local.network_plugin
  net_profile_dns_service_ip        = "192.168.0.10" # IP address within the Kubernetes service address range that will be used by cluster service discovery. Don't use the first IP address in your address range. The first address in your subnet range is used for the kubernetes.default.svc.cluster.local address.
  net_profile_pod_cidr              = "10.244.0.0/16" # for aks pods cidr
  net_profile_docker_bridge_cidr    = "172.17.0.1/16" # It's required to select a CIDR for the Docker bridge network address because otherwise Docker will pick a subnet automatically, which could conflict with other CIDRs. You must pick an address space that doesn't collide with the rest of the CIDRs on your networks, including the cluster's service CIDR and pod CIDR. Default of 172.17.0.1/16.
  net_profile_service_cidr          = "192.168.0.0/16" # This range shouldn't be used by any network element on or connected to this virtual network. Service address CIDR must be smaller than /12. You can reuse this range across different AKS clusters.
  agents_pool_name                  = [format("%sinfra", local.name), format("%sapp", local.name)]
  os_disk_size_gb                   = "30"
  enable_auto_scaling               = "true"
  agents_min_count                  = "1"
  agents_max_count                  = "3"
  enable_node_public_ip             = "false" # If we want to create public nodes set this value "true"
  agents_availability_zones         = ["1", "2", "3"] # Applies to all the regions except Central India
  rbac_enabled                      = "true"
  oidc_issuer                       = "true"
  agents_max_pods                   = "58"
  create_resource_group             = false  # Enable if you want to a create resource group for AKS cluster.
  existing_resource_group_name      = azurerm_resource_group.terraform_infra.name
  resource_group_location           = azurerm_resource_group.terraform_infra.location
  environment                       = local.environment
  name                              = format("%s-aks", local.name)
  kubernetes_version                = local.k8s_version
  private_cluster_enabled           = "false"  # Cluster endpoint access
  sku_tier                          = "Free"
  subnet_id                         = module.vnet.private_subnets
  admin_username                    = "azureuser"  # node pool username
  public_ssh_key                    = tls_private_key.key.public_key_openssh
  agents_type                       = "VirtualMachineScaleSets"  # Creates an Agent Pool backed by a Virtual Machine Scale Set.
  net_profile_outbound_type         = "loadBalancer"   # The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer.
  log_analytics_workspace_sku       = "PerGB2018" # refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
  enable_log_analytics_solution     = "true" # Log analytics solutions are typically software solutions with data visualization and insights tools.
  enable_control_plane_logs_scrape  = "true" # Scrapes logs of the aks control plane
  control_plane_monitor_name        = format("%s-%s-aks-control-plane-logs-monitor", local.name, local.environment) # Control plane logs monitoring such as "kube-apiserver", "cloud-controller-manager", "kube-scheduler"
  additional_tags                   = local.additional_tags
  node_labels_app                   = { App-Services = "true" }
  node_labels_infra                 = { Infra-Services = "true" }
}

module "aks_node_pool" {
  depends_on = [module.aks_cluster]
  source     = "../../modules/aks_node_pool"

  node_pool                  = {}
  kubernetes_cluster_id      = module.aks_cluster.kubernetes_cluster_id
  enable_auto_scaling        = "true"
  enable_node_public_ip      = "false" # If we want to create public nodes set this value "true"
  kubernetes_version         = local.k8s_version
  subnet_id                  = module.vnet.private_subnets
}