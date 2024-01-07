# Azure AKS Terraform module
![squareops_avatar]

[squareops_avatar]: https://squareops.com/wp-content/uploads/2022/12/squareops-logo.png

### [SquareOps Technologies](https://squareops.com/) Your DevOps Partner for Accelerating cloud journey.
<br>
This module simplifies the deployment of AKS clusters, allowing users to quickly create and manage a production-grade Kubernetes cluster on Azure. The module is highly configurable, allowing users to customize various aspects of the AKS cluster, such as the Kubernetes version, worker node instance type, and number of worker nodes. Additionally, the module provides a set of outputs that can be used to configure other resources, such as the Kubernetes config file and the Azure CLI.

This module is ideal for users who want to quickly deploy an AKS cluster on Azure without the need for manual setup and configuration. It is also suitable for users who want to adopt best practices for security and scalability in their AKS deployments.

**Setup SSH Keys for AKS nodes**
1. Generate SSH keys using Azure CLI:
```bash
az sshkey create --name "mySSHKey" --resource-group "myResourceGroup"
```
**The resulting output lists the new key files' paths:**
```bash
Private key is saved to "/home/user/.ssh/7777777777_9999999".
Public key is saved to "/home/user/.ssh/7777777777_9999999.pub".
```
2. Create Azure Key Vault using Azure CLI:
```bash
az keyvault create --name MyKeyVault --resource-group MyResourceGroup --location "East US"
```
3. Set SSH public key in Key Vault using Azure CLI:
```bash
az keyvault secret set --vault-name "MyKeyVault" --name "mySSHKey" --file /home/user/.ssh/7777777777_9999999.pub
```
4. Update the Key Vault name and ID in the Terraform data variables:
Update the `example/complete/main.tf` file with the following values for key vault:
```hcl
data "azurerm_key_vault_secret" "ssh_key" {
  name         = "mySSHKey"
  key_vault_id = "/subscriptions/{subscription-id}/resourceGroups/MyResourceGroup/providers/Microsoft.KeyVault/vaults/MyKeyVault"
}
```
To get the value for `key_vault_id` use the following Azure CLI command:

```bash
az keyvault show --name "MyKeyVault" --query "id"
```

## Usage Example

```hcl
data "azurerm_key_vault_secret" "ssh_key" {
  name         = "test-ssh-key"
  key_vault_id = "/subscriptions/{subscription-id}/resourceGroups/prod-skaf-tfstate-rg/providers/Microsoft.KeyVault/vaults/test-ssh-key-skaf"
}

# There are two types of managed idetities "System assigned" & "UserAssigned". User-assigned managed identities can be used on multiple resources.
resource "azurerm_user_assigned_identity" "identity" {
  name                = "aksidentity"
  resource_group_name = "AKS-resource-group"
  location            = "eastus"
}

module "aks_cluster" {
  depends_on = [module.vnet, azurerm_user_assigned_identity.identity]
  source     = "squareops/aks/azurerm"

  name                               = "aks-cluster"
  environment                        = "prod"
  kubernetes_version                 = "1.26.3"
  create_resource_group              = false  # Enable if you want to a create resource group for AKS cluster.
  existing_resource_group_name       = "AKS-resource-group"
  resource_group_location            = "eastus"
  user_assigned_identity_id          = azurerm_user_assigned_identity.identity.id
  principal_id                       = azurerm_user_assigned_identity.identity.principal_id
  network_plugin                     = "azure"
  net_profile_dns_service_ip         = "192.168.0.10" # IP address within the Kubernetes service address range that will be used by cluster service discovery. Don't use the first IP address in your address range. The first address in your subnet range is used for the kubernetes.default.svc.cluster.local address.
  net_profile_pod_cidr               = "10.244.0.0/16" # For aks pods cidr, when choosen "azure" network plugin these value will be passed as null.
  net_profile_docker_bridge_cidr     = "172.17.0.1/16" # It's required to select a CIDR for the Docker bridge network address because otherwise Docker will pick a subnet automatically, which could conflict with other CIDRs. You must pick an address space that doesn't collide with the rest of the CIDRs on your networks, including the cluster's service CIDR and pod CIDR. Default of 172.17.0.1/16.
  net_profile_service_cidr           = "192.168.0.0/16" # This range shouldn't be used by any network element on or connected to this virtual network. Service address CIDR must be smaller than /12. You can reuse this range across different AKS clusters.
  default_agent_pool_name            = "infra"
  default_agent_pool_count           = "1"
  default_agent_pool_size            = "Standard_DS2_v2"
  host_encryption_enabled            = false
  default_node_labels                = { Addon-Services = "true" }
  os_disk_size_gb                    = 30
  auto_scaling_enabled               = true
  agents_min_count                   = 1
  agents_max_count                   = 2
  node_public_ip_enabled             = false  # If we want to create public nodes set this value "true"
  agents_availability_zones          = ["1", "2", "3"] # Does not applies to all regions please verify the availablity zones for the respective region.
  rbac_enabled                       = true
  oidc_issuer_enabled                = true
  open_service_mesh_enabled          = false  # Add on for the open service mesh (istio)
  private_cluster_enabled            = false  # AKS Cluster endpoint access, Disable for public access
  sku_tier                           = "Free"
  subnet_id                          = ["10.0.0.0/24", "10.0.0.1/24"]
  admin_username                     = "azureuser"  # node pool username
  public_ssh_key                     = data.azurerm_key_vault_secret.ssh_key.value
  agents_type                        = "VirtualMachineScaleSets"  # Creates an Agent Pool backed by a Virtual Machine Scale Set.
  net_profile_outbound_type          = "loadBalancer"   # The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer.
  log_analytics_workspace_sku        = "PerGB2018" # refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
  log_analytics_solution_enabled     = true # Log analytics solutions are typically software solutions with data visualization and insights tools.
  control_plane_logs_scrape_enabled  = true # Scrapes logs of the aks control plane
  control_plane_monitor_name         = format("%s-%s-aks-control-plane-logs-monitor", local.name, local.environment) # Control plane logs monitoring such as "kube-apiserver", "cloud-controller-manager", "kube-scheduler"
  additional_tags                    = local.additional_tags
}

module "aks_managed_node_pool" {
  depends_on = [module.aks_cluster]
  source     = "squareops/aks/azurerm//modules/managed_node_pools"

  resource_group_name   = "AKS-resource-group"
  orchestrator_version  = "1.26.3"
  location              = "eastus"
  vnet_subnet_id        = ["10.0.0.0/24", "10.0.0.1/24"]
  kubernetes_cluster_id = module.aks_cluster.kubernetes_cluster_id
  node_pools = {
    app = {
      vm_size                  = "Standard_DS2_v2"
      auto_scaling_enabled     = true
      os_disk_size_gb          = 50
      os_disk_type             = "Managed"
      node_count               = 1
      min_count                = 1
      max_count                = 2
      availability_zones       = ["1", "2", "3"]
      enable_node_public_ip    = false # if set to true node_public_ip_prefix_id is required
      node_public_ip_prefix_id = ""
      node_labels              = { App-service = "true" }
      node_taints              = ["workload=example:NoSchedule"]
      host_encryption_enabled  = false
      max_pods                 = 30
      agents_tags              = local.additional_tags
    },
 }
}
```

Refer [example](https://github.com/squareops/terraform-azurerm-aks/tree/main/examples/complete) for more details.

## Permissions
The required permissions to create resources from this module can be found [here](https://github.com/squareops/terraform-azurerm-aks/tree/main/roles.md)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.6 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >=2.13.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource-group"></a> [resource-group](#module\_resource-group) | ./modules/resource-group | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_log_analytics_solution.logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_workspace.logs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_diagnostic_setting.control_plane](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_role_assignment.network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [null_resource.open_service_mesh_addon](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.log_analytics_workspace_name_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [azurerm_subscription.primary](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the deployment or resource. (e.g., AKS cluster name, resource group name) | `string` | `""` | no |
| <a name="input_host"></a> [host](#input\_host) | The host or endpoint for the resource. | `string` | `""` | no |
| <a name="input_client_certificate"></a> [client\_certificate](#input\_client\_certificate) | The client certificate for authentication. | `string` | `""` | no |
| <a name="input_client_key"></a> [client\_key](#input\_client\_key) | The client key for authentication. | `string` | `""` | no |
| <a name="input_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#input\_cluster\_ca\_certificate) | The CA certificate used by the cluster. | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment in which the resources are deployed. | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Azure resource group. | `string` | `""` | no |
| <a name="input_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#input\_user\_assigned\_identity\_id) | The ID of the user-assigned identity. | `string` | `""` | no |
| <a name="input_resource_group_location"></a> [resource\_group\_location](#input\_resource\_group\_location) | The location of the Azure resource group. | `string` | `""` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | To create a new resource group. Value in existing\_resource\_group will be ignored if this is true. | `bool` | `false` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | Name of existing resource group that has to be used. Leave empty if new resource group has to be created. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to associate with your network and subnets and aks resources. | `map(string)` | <pre>{<br>  "tag1": "",<br>  "tag2": ""<br>}</pre> | no |
| <a name="input_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#input\_kubernetes\_cluster\_id) | The ID of the Kubernetes cluster. | `string` | `""` | no |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | The Azure Active Directory (AAD) client ID for authentication. | `string` | `""` | no |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | The Azure Active Directory (AAD) client secret for authentication. | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the cluster for AAD configuration. | `string` | `""` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The version of Kubernetes to use in the AKS cluster. | `string` | `""` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The username for the AKS cluster's admin user. | `string` | `""` | no |
| <a name="input_public_ssh_key"></a> [public\_ssh\_key](#input\_public\_ssh\_key) | The public SSH key for the AKS cluster's admin user. | `string` | `""` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | The SKU tier for the AKS cluster. | `string` | `""` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | Indicates whether the AKS cluster is private or public. | `bool` | `false` | no |
| <a name="input_enable_http_application_routing"></a> [enable\_http\_application\_routing](#input\_enable\_http\_application\_routing) | Enables or disables HTTP application routing. | `bool` | `false` | no |
| <a name="input_enable_kube_dashboard"></a> [enable\_kube\_dashboard](#input\_enable\_kube\_dashboard) | Enables or disables the Kubernetes dashboard. | `bool` | `false` | no |
| <a name="input_balance_similar_node_groups"></a> [balance\_similar\_node\_groups](#input\_balance\_similar\_node\_groups) | Indicates whether to balance similar node groups. | `bool` | `true` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Indicates whether to oidc issuer is enabled. | `bool` | `true` | no |
| <a name="input_max_graceful_termination_sec"></a> [max\_graceful\_termination\_sec](#input\_max\_graceful\_termination\_sec) | The maximum time for graceful termination in seconds. | `number` | `600` | no |
| <a name="input_scale_down_delay_after_add"></a> [scale\_down\_delay\_after\_add](#input\_scale\_down\_delay\_after\_add) | The delay duration after adding a node. | `string` | `"10m"` | no |
| <a name="input_scale_down_delay_after_delete"></a> [scale\_down\_delay\_after\_delete](#input\_scale\_down\_delay\_after\_delete) | The delay duration after deleting a node. | `string` | `"10s"` | no |
| <a name="input_scale_down_delay_after_failure"></a> [scale\_down\_delay\_after\_failure](#input\_scale\_down\_delay\_after\_failure) | The delay duration after a failure. | `string` | `"3m"` | no |
| <a name="input_scan_interval"></a> [scan\_interval](#input\_scan\_interval) | The interval duration for scanning. | `string` | `"10s"` | no |
| <a name="input_scale_down_unneeded"></a> [scale\_down\_unneeded](#input\_scale\_down\_unneeded) | The duration before scaling down unneeded nodes. | `string` | `"10m"` | no |
| <a name="input_scale_down_unready"></a> [scale\_down\_unready](#input\_scale\_down\_unready) | The duration before scaling down unready nodes. | `string` | `"20m"` | no |
| <a name="input_scale_down_utilization_threshold"></a> [scale\_down\_utilization\_threshold](#input\_scale\_down\_utilization\_threshold) | The utilization threshold for scaling down. | `number` | `0.5` | no |
| <a name="input_agents_pool_name"></a> [agents\_pool\_name](#input\_agents\_pool\_name) | The names of the agent pools. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_agents_count"></a> [agents\_count](#input\_agents\_count) | The desired number of agents. | `number` | `2` | no |
| <a name="input_agents_min_count"></a> [agents\_min\_count](#input\_agents\_min\_count) | The minimum number of agents. | `number` | `1` | no |
| <a name="input_agents_max_count"></a> [agents\_max\_count](#input\_agents\_max\_count) | The maximum number of agents. | `number` | `3` | no |
| <a name="input_agents_size"></a> [agents\_size](#input\_agents\_size) | The sizes of the agent pools. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_node_taints"></a> [node\_taints](#input\_node\_taints) | The taints for the nodes. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The IDs of the subnets. | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_os_disk_size_gb"></a> [os\_disk\_size\_gb](#input\_os\_disk\_size\_gb) | The size of the OS disk in gigabytes. | `number` | `20` | no |
| <a name="input_auto_scaling_enabled"></a> [auto\_scaling\_enabled](#input\_auto\_scaling\_enabled) | Enables or disables auto-scaling. | `bool` | `false` | no |
| <a name="input_node_public_ip_enabled"></a> [node\_public\_ip\_enabled](#input\_node\_public\_ip\_enabled) | Indicates whether nodes have public IP addresses. | `bool` | `true` | no |
| <a name="input_agents_availability_zones"></a> [agents\_availability\_zones](#input\_agents\_availability\_zones) | The availability zones for the agent pools. | `list(string)` | `null` | no |
| <a name="input_agents_type"></a> [agents\_type](#input\_agents\_type) | The type of agents. | `string` | `""` | no |
| <a name="input_agents_max_pods"></a> [agents\_max\_pods](#input\_agents\_max\_pods) | The maximum number of pods per agent. | `number` | `50` | no |
| <a name="input_network_plugin"></a> [network\_plugin](#input\_network\_plugin) | The network plugin to use. | `string` | `""` | no |
| <a name="input_net_profile_dns_service_ip"></a> [net\_profile\_dns\_service\_ip](#input\_net\_profile\_dns\_service\_ip) | The DNS service IP address. | `string` | `""` | no |
| <a name="input_net_profile_docker_bridge_cidr"></a> [net\_profile\_docker\_bridge\_cidr](#input\_net\_profile\_docker\_bridge\_cidr) | The Docker bridge CIDR. | `string` | `""` | no |
| <a name="input_net_profile_outbound_type"></a> [net\_profile\_outbound\_type](#input\_net\_profile\_outbound\_type) | The outbound type for the network profile. | `string` | `""` | no |
| <a name="input_net_profile_pod_cidr"></a> [net\_profile\_pod\_cidr](#input\_net\_profile\_pod\_cidr) | The pod CIDR. | `string` | `""` | no |
| <a name="input_net_profile_service_cidr"></a> [net\_profile\_service\_cidr](#input\_net\_profile\_service\_cidr) | The service CIDR. | `string` | `""` | no |
| <a name="input_node_pool"></a> [node\_pool](#input\_node\_pool) | The configuration for the node pool. | `any` | `{}` | no |
| <a name="input_rbac_enabled"></a> [rbac\_enabled](#input\_rbac\_enabled) | Indicates whether RBAC (Role-Based Access Control) is enabled. | `bool` | `false` | no |
| <a name="input_log_analytics_workspace_sku"></a> [log\_analytics\_workspace\_sku](#input\_log\_analytics\_workspace\_sku) | Name of the log analytics workspace sku tier | `string` | `"PerGB2018"` | no |
| <a name="input_log_analytics_solution_enabled"></a> [log\_analytics\_solution\_enabled](#input\_log\_analytics\_solution\_enabled) | Enable or disable log analytics solution | `bool` | `true` | no |
| <a name="input_log_analytics_solution_name"></a> [log\_analytics\_solution\_name](#input\_log\_analytics\_solution\_name) | Name of the log analytics solution resource | `string` | `""` | no |
| <a name="input_control_plane_logs_scrape_enabled"></a> [control\_plane\_logs\_scrape\_enabled](#input\_control\_plane\_logs\_scrape\_enabled) | Enable or disable control plane logs scraping | `bool` | `true` | no |
| <a name="input_control_plane_monitor_name"></a> [control\_plane\_monitor\_name](#input\_control\_plane\_monitor\_name) | Name of the azure monitor diagostic setting resource which scraps logs of control plane logs monitoring such as kube-apiserver, cloud-controller-manager, kube-scheduler, kube-controller-manager etc. | `string` | `""` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags for best practices | `any` | `{}` | no |
| <a name="input_principal_id"></a> [principal\_id](#input\_principal\_id) | AKS identity principal ID | `string` | `""` | no |
| <a name="input_node_labels_app"></a> [node\_labels\_app](#input\_node\_labels\_app) | The node labels to be attached to be attached to the aks app node pool | `map(string)` | `{}` | no |
| <a name="input_node_labels_infra"></a> [node\_labels\_infra](#input\_node\_labels\_infra) | The node labels to be attached to be attached to the aks infra node pool | `map(string)` | `{}` | no |
| <a name="input_auto_scaling_app_enabled"></a> [auto\_scaling\_app\_enabled](#input\_auto\_scaling\_app\_enabled) | Whether to enable auto scaling for the app node pool | `bool` | `true` | no |
| <a name="input_agents_count_app"></a> [agents\_count\_app](#input\_agents\_count\_app) | The initial number of agents for the app node pool | `string` | `"1"` | no |
| <a name="input_agents_min_count_app"></a> [agents\_min\_count\_app](#input\_agents\_min\_count\_app) | The minimum number of agents for the app node pool | `string` | `"1"` | no |
| <a name="input_agents_max_count_app"></a> [agents\_max\_count\_app](#input\_agents\_max\_count\_app) | The maximum number of agents for the app node pool | `string` | `"3"` | no |
| <a name="input_agents_availability_zones_app"></a> [agents\_availability\_zones\_app](#input\_agents\_availability\_zones\_app) | The availability zones for the app node pool | `list(string)` | <pre>[<br>  "1",<br>  "2"<br>]</pre> | no |
| <a name="input_auto_scaling_monitor_enabled"></a> [auto\_scaling\_monitor\_enabled](#input\_auto\_scaling\_monitor\_enabled) | Whether to enable auto scaling for the monitor node pool | `bool` | `true` | no |
| <a name="input_agents_count_monitor"></a> [agents\_count\_monitor](#input\_agents\_count\_monitor) | The initial number of agents for the monitor node pool | `string` | `"1"` | no |
| <a name="input_agents_min_count_monitor"></a> [agents\_min\_count\_monitor](#input\_agents\_min\_count\_monitor) | The minimum number of agents for the monitor node pool | `string` | `"1"` | no |
| <a name="input_agents_max_count_monitor"></a> [agents\_max\_count\_monitor](#input\_agents\_max\_count\_monitor) | The maximum number of agents for the monitor node pool | `string` | `"3"` | no |
| <a name="input_agents_availability_zones_monitor"></a> [agents\_availability\_zones\_monitor](#input\_agents\_availability\_zones\_monitor) | The availability zones for the monitor node pool | `list(string)` | <pre>[<br>  "1",<br>  "2"<br>]</pre> | no |
| <a name="input_node_labels_monitor"></a> [node\_labels\_monitor](#input\_node\_labels\_monitor) | The labels for the monitor node pool | `map(string)` | <pre>{<br>  "Monitor-Services": "true"<br>}</pre> | no |
| <a name="input_auto_scaling_database_enabled"></a> [auto\_scaling\_database\_enabled](#input\_auto\_scaling\_database\_enabled) | Whether to enable auto scaling for the database node pool | `bool` | `true` | no |
| <a name="input_agents_count_database"></a> [agents\_count\_database](#input\_agents\_count\_database) | The initial number of agents for the database node pool | `string` | `"1"` | no |
| <a name="input_agents_min_count_database"></a> [agents\_min\_count\_database](#input\_agents\_min\_count\_database) | The minimum number of agents for the database node pool | `string` | `"1"` | no |
| <a name="input_agents_max_count_database"></a> [agents\_max\_count\_database](#input\_agents\_max\_count\_database) | The maximum number of agents for the database node pool | `string` | `"3"` | no |
| <a name="input_agents_availability_zones_database"></a> [agents\_availability\_zones\_database](#input\_agents\_availability\_zones\_database) | The availability zones for the database node pool | `list(string)` | <pre>[<br>  "1",<br>  "2"<br>]</pre> | no |
| <a name="input_node_labels_database"></a> [node\_labels\_database](#input\_node\_labels\_database) | The labels for the database node pool | `map(string)` | <pre>{<br>  "Database-Services": "true"<br>}</pre> | no |
| <a name="input_default_agent_pool_name"></a> [default\_agent\_pool\_name](#input\_default\_agent\_pool\_name) | The name of the default agent pool | `string` | `"infra"` | no |
| <a name="input_default_agent_pool_count"></a> [default\_agent\_pool\_count](#input\_default\_agent\_pool\_count) | The number of agents in the default agent pool | `string` | `"1"` | no |
| <a name="input_default_agent_pool_size"></a> [default\_agent\_pool\_size](#input\_default\_agent\_pool\_size) | The size of the default agent pool | `string` | `"Standard_DS2_v2"` | no |
| <a name="input_default_node_labels"></a> [default\_node\_labels](#input\_default\_node\_labels) | The labels for the default agent pool | `map(string)` | <pre>{<br>  "Infra-Services": "true"<br>}</pre> | no |
| <a name="input_host_encryption_enabled"></a> [host\_encryption\_enabled](#input\_host\_encryption\_enabled) | The enable the encryption of the hosts | `bool` | `false` | no |
| <a name="input_open_service_mesh_enabled"></a> [open\_service\_mesh\_enabled](#input\_open\_service\_mesh\_enabled) | The enable the open service mesg (istio) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster Name |
| <a name="output_default_ng_rg_name"></a> [default\_ng\_rg\_name](#output\_default\_ng\_rg\_name) | Default Node Group Resource Group Name |
| <a name="output_kubernetes_cluster_id"></a> [kubernetes\_cluster\_id](#output\_kubernetes\_cluster\_id) | kubernetes cluster id |
| <a name="output_host"></a> [host](#output\_host) | host |
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | client\_certificate |
| <a name="output_client_key"></a> [client\_key](#output\_client\_key) | client\_key |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | cluster\_ca\_certificate |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contribution & Issue Reporting

To report an issue with a project:

  1. Check the repository's [issue tracker](https://github.com/squareops/terraform-azurerm-aks/issues) on GitHub
  2. Search to see if the issue has already been reported
  3. If you can't find an answer to your question in the documentation or issue tracker, you can ask a question by creating a new issue. Be sure to provide enough context and details so others can understand your problem.

## License

Apache License, Version 2.0, January 2004 (http://www.apache.org/licenses/).

## Support Us

To support a GitHub project by liking it, you can follow these steps:

  1. Visit the repository: Navigate to the [GitHub repository](https://github.com/squareops/terraform-azurerm-aks).

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
