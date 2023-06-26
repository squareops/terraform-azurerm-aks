# Azure AKS Terraform module
![squareops_avatar]

[squareops_avatar]: https://squareops.com/wp-content/uploads/2022/12/squareops-logo.png

### [SquareOps Technologies](https://squareops.com/) Your DevOps Partner for Accelerating cloud journey.
<br>
This module simplifies the deployment of AKS clusters, allowing users to quickly create and manage a production-grade Kubernetes cluster on Azure. The module is highly configurable, allowing users to customize various aspects of the AKS cluster, such as the Kubernetes version, worker node instance type, and number of worker nodes. Additionally, the module provides a set of outputs that can be used to configure other resources, such as the Kubernetes config file and the Azure CLI.

This module is ideal for users who want to quickly deploy an AKS cluster on Azure without the need for manual setup and configuration. It is also suitable for users who want to adopt best practices for security and scalability in their AKS deployments.


## Usage Example

```hcl
module "aks_cluster" {
 depends_on = [module.vnet, azurerm_user_assigned_identity.identity]
  source     = "squareops/aks/azure"

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
  existing_resource_group_name      = "aks-resource-group"
  resource_group_location           = "eastus"
  environment                       = "prod"
  name                              = format("%s-aks", local.name)
  kubernetes_version                = local.k8s_version
  private_cluster_enabled           = "false"  # Cluster endpoint access
  sku_tier                          = "Free"
  subnet_id                         = ["private-subnet-id-1","private-subnet-id-2"]
  admin_username                    = "azureuser"  # node pool username
  public_ssh_key                    = tls_private_key.key.public_key_openssh
  agents_type                       = "VirtualMachineScaleSets"  # Creates an Agent Pool backed by a Virtual Machine Scale Set.
  net_profile_outbound_type         = "loadBalancer"           # The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer.
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
  subnet_id                  = ["private-subnet-id-1","private-subnet-id-2"]
}
```

Refer [example](https://github.com/sq-ia/terraform-azure-aks/tree/release/v1) for more details.

## Permissions
The required permissions to create resources from this module can be found [here](https://github.com/sq-ia/terraform-azure-aks/tree/release/v1/roles.md)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_azure"></a> [azurerm](#requirement\_azure) | >= 3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azure"></a> [azure](#provider\_azure) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aks_cluster"></a> [aks_cluster](#module\_aks_cluster) | ./modules/aks_cluster | 1.0 |
| <a name="module_aks_node_pool"></a> [aks_node_pool](#module\_aks_node_pool) | ./modules/aks_node_pool | 1.0 |
| <a name="module_vnet"></a> [vnet](#module\_vnet) | squareops/vnet/azure | 1.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_user_assigned_identity](https://registry.terraform.io/providers/hashicorp/azurerm/2.62.1/docs/resources/user_assigned_identity) | resource |

## Inputs

| Variable                           | Description                                                                                                                               | Type          | Default Value | Required     |
|------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|---------------|---------------|--------------|
| <a name="input_name"></a> [name](#input_name) | The name of the deployment or resource. (e.g., AKS cluster name, resource group name)                                                    | `string`      | `""`          | No           |
| <a name="input_environment"></a> [environment](#input_environment) | The environment in which the resources are deployed.                                                                                    | `string`      | `""`          | No           |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | The name of the Azure resource group.                                                                                    | `string`      | `""`          | No           |
| <a name="input_resource_group_location"></a> [resource_group_location](#input_resource_group_location) | The location of the Azure resource group.                                                                                    | `string`      | `""`          | No           |
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name) | The name of the cluster for AAD configuration.                                                                                    | `string`      | `""`          | No             |
| <a name="input_kubernetes_version"></a> [kubernetes_version](#input_kubernetes_version) | The version of Kubernetes to use in the AKS cluster.                                                                                    | `string`      | `""`          |   No           |
| <a name="input_admin_username"></a> [admin_username](#input_admin_username) | The username for the AKS cluster's admin user.                                                                                    | `string`      | `""`          |     No         |
| <a name="input_public_ssh_key"></a> [public_ssh_key](#input_public_ssh_key) | The public SSH key for the AKS cluster's admin user.                                                                                    | `string`      | `""`          |   No           |
| <a name="input_sku_tier"></a> [sku_tier](#input_sku_tier) | The SKU tier for the AKS cluster.                                                                                    | `string`      | `""`          |    No          |
| <a name="input_private_cluster_enabled"></a> [private_cluster_enabled](#input_private_cluster_enabled) | Indicates whether the AKS cluster is private or public.                                                                                    | `bool`        | `false`       |     No         |
| <a name="input_agents_pool_name"></a> [agents_pool_name](#input_agents_pool_name) | The names of the agent pools.                                                                                    | `list(string)` | `[""]`        |     No         |
| <a name="input_agents_count"></a> [agents_count](#input_agents_count) | The desired number of agents.                                                                                    | `number`      | `2`           |   No           |
| <a name="input_agents_min_count"></a> [agents_min_count](#input_agents_min_count) | The minimum number of agents.                                                                                    | `number`      | `1`           |     No         |
| <a name="input_agents_max_count"></a> [agents_max_count](#input_agents_max_count) | The maximum number of agents.                                                                                    | `number`      | `3`           |    No          |
| <a name="input_agents_size"></a> [agents_size](#input_agents_size) | The sizes of the agent pools.                                                                                                                                                             | `list(string)` | `[""]`        |    No          |
| <a name="input_subnet_id"></a> [subnet_id](#input_subnet_id) | The IDs of the subnets.                                                                                    | `list(string)` | `[""]`        |     No         |
| <a name="input_os_disk_size_gb"></a> [os_disk_size_gb](#input_os_disk_size_gb) | The size of the OS disk in gigabytes.                                                                                    | `number`      | `30`          |     No         |
| <a name="input_enable_auto_scaling"></a> [enable_auto_scaling](#input_enable_auto_scaling) | Enables or disables auto-scaling.                                                                                    | `bool`        | `false`       |    No         |
| <a name="input_enable_node_public_ip"></a> [enable_node_public_ip](#input_enable_node_public_ip) | Indicates whether nodes have public IP addresses.                                                                                    | `bool`        | `true`        |     No         |
| <a name="input_agents_availability_zones"></a> [agents_availability_zones](#input_agents_availability_zones) | The availability zones for the agent pools.                                                                                    | `list(string)` | `null`        |      No        |
| <a name="input_agents_type"></a> [agents_type](#input_agents_type) | The type of agents.                                                                                    | `string`      | `""`          |     No         |
| <a name="input_agents_max_pods"></a> [agents_max_pods](#input_agents_max_pods) | The maximum number of pods per agent.                                                                                    | `number`      | `58`          |     No         |
| <a name="input_network_plugin"></a> [network_plugin](#input_network_plugin) | The network plugin to use.                                                                                    | `string`      | `""`          |      No        |
| <a name="input_net_profile_dns_service_ip"></a> [net_profile_dns_service_ip](#input_net_profile_dns_service_ip) | The DNS service IP address.                                                                                    | `string`      | `""`          |     No         |
| <a name="input_net_profile_docker_bridge_cidr"></a> [net_profile_docker_bridge_cidr](#input_net_profile_docker_bridge_cidr) | The Docker bridge CIDR.                                                                                    | `string`      | `""`          |     No         |
| <a name="input_net_profile_outbound_type"></a> [net_profile_outbound_type](#input_net_profile_outbound_type) | The outbound type for the network profile.                                                                                    | `string`      | `""`          |     No         |
| <a name="input_net_profile_pod_cidr"></a> [net_profile_pod_cidr](#input_net_profile_pod_cidr) | The pod CIDR.                                                                                    | `string`      | `""`          |    No          |
| <a name="input_net_profile_service_cidr"></a> [net_profile_service_cidr](#input_net_profile_service_cidr) | The service CIDR.                                                                                    | `string`      | `""`          |     No         |
| <a name="input_rbac_enabled"></a> [rbac_enabled](#input_rbac_enabled) | Indicates whether RBAC (Role Based Access Control) is enabled or disabled | `bool` | `true`        |     No         |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output_name) | Common Name for namming resource groups, vnet, aks, aks node pools etc|
| <a name="output_environment"></a> [environment](#output_environment) | Environment Name for specifiying environment tagging resource groups, vnet, aks, aks node pools etc|
| <a name="output_cluster_name"></a> [cluster_name](#output_cluster_name) | Azure Kubernetes Cluster Name |
| <a name="output_default_ng_rg_name"></a> [default_ng_rg_name](#output_default_ng_rg_name) | Default Node Group Resource Group Name |
| <a name="output_resource_group_name"></a> [resource_group_name](#output_resource_group_name) | Resource Group Name |
| <a name="output_resource_group_location"></a> [resource_group_location](#output_resource_group_location) | Resource Group Name Location |
| <a name="output_vnet_id"></a> [vnet_id](#output_vnet_id) | ID of the Vnet |
| <a name="output_vnet_name"></a> [vnet_name](#output_vnet_name) | The Name of the newly created vNet |
| <a name="output_vnet_subnets_name_id"></a> [vnet_subnets_name_id](#output_vnet_subnets_name_id) | Can be queried subnet-id by subnet name by using `lookup(module.vnet.vnet_subnets_name_id, subnet1)` |
| <a name="output_user_assigned_identity_id"></a> [user_assigned_identity_id](#output_user_assigned_identity_id) | User assigned identity ID for CNI |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contribution & Issue Reporting

To report an issue with a project:

  1. Check the repository's [issue tracker](https://github.com/squareops/terraform-azure-aks/issues) on GitHub
  2. Search to see if the issue has already been reported
  3. If you can't find an answer to your question in the documentation or issue tracker, you can ask a question by creating a new issue. Be sure to provide enough context and details so others can understand your problem.

## License

Apache License, Version 2.0, January 2004 (http://www.apache.org/licenses/).

## Support Us

To support a GitHub project by liking it, you can follow these steps:

  1. Visit the repository: Navigate to the [GitHub repository](https://github.com/squareops/terraform-azure-aks).

  2. Click the "Star" button: On the repository page, you'll see a "Star" button in the upper right corner. Clicking on it will star the repository, indicating your support for the project.

  3. Optionally, you can also leave a comment on the repository or open an issue to give feedback or suggest changes.

Starring a repository on GitHub is a simple way to show your support and appreciation for the project. It also helps to increase the visibility of the project and make it more discoverable to others.

## Who we are

We believe that the key to success in the digital age is the ability to deliver value quickly and reliably. That’s why we offer a comprehensive range of DevOps & Cloud services designed to help your organization optimize its systems & Processes for speed and agility.

  1. We are an AWS Advanced consulting partner which reflects our deep expertise in AWS Cloud and helping 100+ clients over the last 4 years.
  2. Expertise in Kubernetes and overall container solution helps companies expedite their journey by 10X.
  3. Infrastructure Automation is a key component to the success of our Clients and our Expertise helps deliver the same in the shortest time.
  4. DevSecOps as a service to implement security within the overall DevOps process and helping companies deploy securely and at speed.
  5. Platform engineering which supports scalable,Cost efficient infrastructure that supports rapid development, testing, and deployment.
  6. 24*7 SRE service to help you Monitor the state of your infrastructure and eradicate any issue within the SLA.

We provide [support](https://squareops.com/contact-us/) on all of our projects, no matter how small or large they may be.

To find more information about our company, visit [squareops.com](https://squareops.com/), follow us on [Linkedin](https://www.linkedin.com/company/squareops-technologies-pvt-ltd/), or fill out a [job application](https://squareops.com/careers/). If you have any questions or would like assistance with your cloud strategy and implementation, please don't hesitate to [contact us](https://squareops.com/contact-us/).