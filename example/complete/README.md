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