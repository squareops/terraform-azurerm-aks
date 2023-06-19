variable "name" {
  default = ""
  type    = string
  description = "The name of the deployment or resource. (e.g., AKS cluster name, resource group name)"
}

variable "host" {
  default = ""
  type    = string
  description = "The host or endpoint for the resource."
}

variable "client_certificate" {
  default = ""
  type    = string
  description = "The client certificate for authentication."
}

variable "client_key" {
  default = ""
  type    = string
  description = "The client key for authentication."
}

variable "cluster_ca_certificate" {
  default = ""
  type    = string
  description = "The CA certificate used by the cluster."
}

variable "environment" {
  default = ""
  type    = string
  description = "The environment in which the resources are deployed."
}

variable "resource_group_name" {
  default = ""
  type    = string
  description = "The name of the Azure resource group."
}

variable "user_assigned_identity_id" {
  default = ""
  type    = string
  description = "The ID of the user-assigned identity."
}

variable "resource_group_location" {
  default = ""
  type    = string
  description = "The location of the Azure resource group."
}

variable "kubernetes_cluster_id" {
  default = ""
  type    = string
  description = "The ID of the Kubernetes cluster."
}

## AZURE ACTIVE DIRECTORY CONFIGURATION VARIABLES

variable "client_id" {
  default = ""
  type    = string
  description = "The Azure Active Directory (AAD) client ID for authentication."
}

variable "client_secret" {
  default = ""
  type    = string
  description = "The Azure Active Directory (AAD) client secret for authentication."
}

variable "cluster_name" {
  default = ""
  type    = string
  description = "The name of the cluster for AAD configuration."
}

## AKS VARIABLES

variable "kubernetes_version" {
  default = ""
  type    = string
  description = "The version of Kubernetes to use in the AKS cluster."
}

variable "admin_username" {
  default = ""
  type    = string
  description = "The username for the AKS cluster's admin user."
}

variable "public_ssh_key" {
  default = ""
  type    = string
  description = "The public SSH key for the AKS cluster's admin user."
}

variable "sku_tier" {
  default = ""
  type    = string
  description = "The SKU tier for the AKS cluster."
}

variable "private_cluster_enabled" {
  default = false
  type    = bool
  description = "Indicates whether the AKS cluster is private or public."
}

variable "enable_http_application_routing" {
  default = false
  type    = bool
  description = "Enables or disables HTTP application routing."
}

variable "enable_kube_dashboard" {
  default = false
  type    = bool
  description = "Enables or disables the Kubernetes dashboard."
}

variable "balance_similar_node_groups" {
  default = true
  type    = bool
  description = "Indicates whether to balance similar node groups."
}

variable "oidc_issuer" {
  default = true
  type    = bool
  description = "Indicates whether to oidc issuer is enabled."
}

variable "max_graceful_termination_sec" {
  default = 600
  type    = number
  description = "The maximum time for graceful termination in seconds."
}

variable "scale_down_delay_after_add" {
  default = "10m"
  type    = string
  description = "The delay duration after adding a node."
}

variable "scale_down_delay_after_delete" {
  default = "10s"
  type    = string
  description = "The delay duration after deleting a node."
}

variable "scale_down_delay_after_failure" {
  default = "3m"
  type    = string
  description = "The delay duration after a failure."
}

variable "scan_interval" {
  default = "10s"
  type    = string
  description = "The interval duration for scanning."
}

variable "scale_down_unneeded" {
  default = "10m"
  type    = string
  description = "The duration before scaling down unneeded nodes."
}

variable "scale_down_unready" {
  default = "20m"
  type    = string
  description = "The duration before scaling down unready nodes."
}

variable "scale_down_utilization_threshold" {
  default = 0.5
  type    = number
  description = "The utilization threshold for scaling down."
}

variable "agents_pool_name" {
  default = [""]
  type    = list(string)
  description = "The names of the agent pools."
}

variable "agents_count" {
  default = 2
  type    = number
  description = "The desired number of agents."
}

variable "agents_min_count" {
  default = 1
  type    = number
  description = "The minimum number of agents."
}

variable "agents_max_count" {
  default = 3
  type    = number
  description = "The maximum number of agents."
}

variable "agents_size" {
  default = [""]
  type    = list(string)
  description = "The sizes of the agent pools."
}

variable "node_taints" {
  default = [""]
  type    = list(string)
  description = "The taints for the nodes."
}

variable "subnet_id" {
  default = [""]
  type    = list(string)
  description = "The IDs of the subnets."
}

variable "os_disk_size_gb" {
  default = 20
  type    = number
  description = "The size of the OS disk in gigabytes."
}

variable "enable_auto_scaling" {
  default = false
  type    = bool
  description = "Enables or disables auto-scaling."
}

variable "enable_node_public_ip" {
  default = true
  type    = bool
  description = "Indicates whether nodes have public IP addresses."
}

variable "agents_availability_zones" {
  default = null
  type    = list(string)
  description = "The availability zones for the agent pools."
}

variable "agents_type" {
  default = ""
  type    = string
  description = "The type of agents."
}

variable "agents_max_pods" {
  default = 50
  type    = number
  description = "The maximum number of pods per agent."
}

variable "network_plugin" {
  default = ""
  type    = string
  description = "The network plugin to use."
}

variable "net_profile_dns_service_ip" {
  default = ""
  type    = string
  description = "The DNS service IP address."
}

variable "net_profile_docker_bridge_cidr" {
  default = ""
  type    = string
  description = "The Docker bridge CIDR."
}

variable "net_profile_outbound_type" {
  default = ""
  type    = string
  description = "The outbound type for the network profile."
}

variable "net_profile_pod_cidr" {
  default = ""
  type    = string
  description = "The pod CIDR."
}

variable "net_profile_service_cidr" {
  default = ""
  type    = string
  description = "The service CIDR."
}

variable "node_pool" {
  default = {}
  type    = any
  description = "The configuration for the node pool."
}

variable "rbac_enabled" {
  default = false
  type    = bool
  description = "Indicates whether RBAC (Role-Based Access Control) is enabled."
}

# Azure log analytics

variable "log_analytics_workspace_sku" {
  description = "Name of the log analytics workspace sku tier" # refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing
  type        = string
  default     = "PerGB2018"
}

variable "enable_log_analytics_solution" {
  description = "Enable or disable log analytics solution"
  type        = bool
  default     = true
}

variable "log_analytics_solution_name" {
  description = "Name of the log analytics solution resource"
  default = ""
  type    = string
}

variable "enable_control_plane_logs_scrape" {
  description = "Enable or disable control plane logs scraping"
  type        = bool
  default     = true
}

variable "control_plane_monitor_name" {
  description = "Name of the azure monitor diagostic setting resource which scraps logs of control plane logs monitoring such as kube-apiserver, cloud-controller-manager, kube-scheduler, kube-controller-manager etc."
  default = ""
  type    = string
}

variable "additional_tags" {
  description = "Additional tags for best practices"
  default = {}
  type    = any
}

variable "principal_id" {
  description = "AKS identity principal ID"
  default = ""
  type    = string
}

variable "node_labels_app" {
  description = "The node labels to be attached to be attached to the aks app node pool"
  type        = map(string)
  default     = {}
}

variable "node_labels_infra" {
  description = "The node labels to be attached to be attached to the aks infra node pool"
  type        = map(string)
  default     = {}
}