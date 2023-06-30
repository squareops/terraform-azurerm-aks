locals {
  region            = "East US"
  environment       = "demo"
  name              = "skaf"
  address_space     = "20.10.0.0/16"
  network_plugin    = "kubenet"    # You can choose "kubenet(basic)" or "azure(advanced)" refer https://learn.microsoft.com/en-us/azure/aks/concepts-network#kubenet-basic-networking 
  k8s_version       = "1.26.3"     # Kubernetes cluster version
}

module "vnet" {
  depends_on  = [azurerm_resource_group.terraform_infra]
  source      = "git::https://github.com/anoushkaakhourysq/terraform-azure-vnet.git?ref=release/v1"

  name                          = local.name
  address_space                 = local.address_space
  environment                   = local.environment
  num_public_subnets            = "1"
  num_private_subnets           = "1"
  num_database_subnets          = "0"
  create_resource_group         = false
  existing_resource_group_name  = azurerm_resource_group.terraform_infra.name
  resource_group_location       = local.region
  create_vpn                    = false
  create_nat_gateway            = true
  enable_logging                = false
  additional_tags               = local.additional_tags
}

data "azurerm_key_vault_secret" "ssh_key" {
  name         = "test-ssh-key"
  key_vault_id = "/subscriptions/f9c51073-abc1-4a5d-8b8f-0b8f57a78829/resourceGroups/prod-skaf-tfstate-rg/providers/Microsoft.KeyVault/vaults/test-ssh-key-skaf"
}

# There are two types of managed idetities "System assigned" & "UserAssigned". User-assigned managed identities can be used on multiple resources.
resource "azurerm_user_assigned_identity" "identity" {
  name                = "aksidentity"
  resource_group_name = azurerm_resource_group.terraform_infra.name
  location            = azurerm_resource_group.terraform_infra.location
}

module "aks_cluster" {
  depends_on = [module.vnet, azurerm_user_assigned_identity.identity]
  source     = "git::https://github.com/prajwalakhuj/terraform-azure-aks.git?ref=release/v1"

  name                               = format("%s-aks", local.name)
  environment                        = local.environment
  kubernetes_version                 = local.k8s_version
  create_resource_group              = false  # Enable if you want to a create resource group for AKS cluster.
  existing_resource_group_name       = azurerm_resource_group.terraform_infra.name
  resource_group_location            = azurerm_resource_group.terraform_infra.location
  user_assigned_identity_id          = azurerm_user_assigned_identity.identity.id
  principal_id                       = azurerm_user_assigned_identity.identity.principal_id
  agents_size                        = ["Standard_DS2_v2", "Standard_DS2_v2"]  # node pool vm sizes in this list (0 for infra, 1 for app )
  network_plugin                     = local.network_plugin
  net_profile_dns_service_ip         = "192.168.0.10" # IP address within the Kubernetes service address range that will be used by cluster service discovery. Don't use the first IP address in your address range. The first address in your subnet range is used for the kubernetes.default.svc.cluster.local address.
  net_profile_pod_cidr               = "10.244.0.0/16" # For aks pods cidr, when choosen "azure" network plugin these value will be passed as null.
  net_profile_docker_bridge_cidr     = "172.17.0.1/16" # It's required to select a CIDR for the Docker bridge network address because otherwise Docker will pick a subnet automatically, which could conflict with other CIDRs. You must pick an address space that doesn't collide with the rest of the CIDRs on your networks, including the cluster's service CIDR and pod CIDR. Default of 172.17.0.1/16.
  net_profile_service_cidr           = "192.168.0.0/16" # This range shouldn't be used by any network element on or connected to this virtual network. Service address CIDR must be smaller than /12. You can reuse this range across different AKS clusters.
  default_agent_pool_name            = "infra"
  default_agent_pool_count           = "1"
  default_agent_pool_size            = "Standard_DS2_v2"
  enable_host_encryption             = false
  default_node_labels                = { Infra-Services = "true" }
  managed_agent_pool_count           = "0"  # number of managed node pools to be created.
  managed_agent_pool_size            = "Standard_DS2_v2"  # Agent size to mapped to the managed node pools.
  os_disk_size_gb                    = "30"
  enable_auto_scaling                = true
  agents_min_count                   = "1"
  agents_max_count                   = "3"
  enable_node_public_ip              = false  # If we want to create public nodes set this value "true"
  agents_availability_zones          = ["1", "2", "3"] # Does not applies to all regions please verify the availablity zones for the respective region.
  rbac_enabled                       = true
  oidc_issuer                        = true
  private_cluster_enabled            = false  # AKS Cluster endpoint access, Disable for public access
  sku_tier                           = "Free"
  subnet_id                          = module.vnet.private_subnets
  admin_username                     = "azureuser"  # node pool username
  public_ssh_key                     = data.azurerm_key_vault_secret.ssh_key.value
  agents_type                        = "VirtualMachineScaleSets"  # Creates an Agent Pool backed by a Virtual Machine Scale Set.
  net_profile_outbound_type          = "loadBalancer"   # The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer.
  log_analytics_workspace_sku        = "PerGB2018" # refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
  enable_log_analytics_solution      = true # Log analytics solutions are typically software solutions with data visualization and insights tools.
  enable_control_plane_logs_scrape   = true # Scrapes logs of the aks control plane
  control_plane_monitor_name         = format("%s-%s-aks-control-plane-logs-monitor", local.name, local.environment) # Control plane logs monitoring such as "kube-apiserver", "cloud-controller-manager", "kube-scheduler"
  additional_tags                    = local.additional_tags
# Managed node pool App
  create_managed_node_pool_app       = true
  managed_node_pool_app_name         = "app"
  managed_node_pool_app_size         = "Standard_DS2_v2"
  enable_auto_scaling_app            = true
  agents_count_app                   = "1"
  agents_min_count_app               = "1"
  agents_max_count_app               = "3"
  agents_availability_zones_app      = ["1", "2"]
  node_labels_app                    = { App-Services = "true" }
# Managed node pool Monitor
  create_managed_node_pool_monitor   = false
  managed_node_pool_monitor_name     = "monitor"
  managed_node_pool_monitor_size     = "Standard_DS2_v2"
  enable_auto_scaling_monitor        = true
  agents_count_monitor               = "1"
  agents_min_count_monitor           = "1"
  agents_max_count_monitor           = "3"
  agents_availability_zones_monitor  = ["1", "2"]
  node_labels_monitor                = { Monitor-Services = "true" }
# Managed node pool Database
  create_managed_node_pool_database  = false
  managed_node_pool_database_name    = "database"
  managed_node_pool_database_size    = "Standard_DS2_v2"
  enable_auto_scaling_database       = true
  agents_count_database              = "1"
  agents_min_count_database          = "1"
  agents_max_count_database          = "3"
  agents_availability_zones_database = ["1", "2"]
  node_labels_database               = { Database-Services = "true" }
}