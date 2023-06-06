# Azure AKS Terraform module
![squareops_avatar]

[squareops_avatar]: https://squareops.com/wp-content/uploads/2022/12/squareops-logo.png

### [SquareOps Technologies](https://squareops.com/) Your DevOps Partner for Accelerating cloud journey.
<br>
This module simplifies the deployment of AKS clusters, allowing users to quickly create and manage a production-grade Kubernetes cluster on Azure. The module is highly configurable, allowing users to customize various aspects of the AKS cluster, such as the Kubernetes version, worker node instance type, and number of worker nodes. Additionally, the module provides a set of outputs that can be used to configure other resources, such as the Kubernetes config file and the Azure CLI.

This module is ideal for users who want to quickly deploy an AKS cluster on Azure without the need for manual setup and configuration. It is also suitable for users who want to adopt best practices for security and scalability in their AKS deployments.


## Usage Example

```hcl
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
  agents_size                       = ["Standard_B2s", "Standard_DS2_v2"]  # node pool vm sizes
  network_plugin                    = local.network_plugin
  net_profile_dns_service_ip        = "192.168.0.10"
  net_profile_docker_bridge_cidr    = "172.17.0.1/16"
  net_profile_pod_cidr              = "10.244.0.0/16"
  net_profile_service_cidr          = "192.168.0.0/16"
  agents_pool_name                  = [format("%sinfra", local.name), format("%sapp", local.name)]
  os_disk_size_gb                   = "30"
  enable_auto_scaling               = "true"
  agents_min_count                  = "1"
  agents_max_count                  = "3"
  enable_node_public_ip             = "true"
  agents_availability_zones         = ["1", "2", "3"] # Cannot apply all the 3 zones for region Central India region
  rbac_enabled                      = "true"
  agents_max_pods                   = "58"
  resource_group_name               = azurerm_resource_group.terraform_infra.name
  resource_group_location           = azurerm_resource_group.terraform_infra.location
  environment                       = local.environment
  name                              = format("%s-aks", local.name)
  kubernetes_version                = local.k8s_version
  private_cluster_enabled           = "false"  # Cluster endpoint
  sku_tier                          = "Free"
  enable_http_application_routing   = "false"
  subnet_id                         = module.security_groups_subnet_route_table_association.subnet_id
  admin_username                    = "azureuser"
  public_ssh_key                    = tls_private_key.key.public_key_openssh
  agents_type                       = "VirtualMachineScaleSets"
  net_profile_outbound_type         = "loadBalancer"
  enable_kube_dashboard             = "false"
}

module "aks_node_pool" {
  depends_on = [module.aks_cluster]
  source     = "../../modules/aks_node_pool"

  node_pool                  = {}
  kubernetes_cluster_id      = module.aks_cluster.kubernetes_cluster_id
  enable_auto_scaling        = "true"
  enable_node_public_ip      = "false"
  kubernetes_version         = local.k8s_version
  subnet_id                  = module.security_groups_subnet_route_table_association.subnet_id
}
```

Refer example for more details.
