variable "name" {
  default = ""
  type    = string
}
variable "host" {
  default = ""
  type    = string
}
variable "client_certificate" {
  default = ""
  type    = string
}
variable "client_key" {
  default = ""
  type    = string
}
variable "cluster_ca_certificate" {
  default = ""
  type    = string
}
variable "environment" {
  default = ""
  type    = string
}

variable "resource_group_name" {
  default = ""
  type    = string
}
variable "user_assigned_identity_id" {
  default = ""
  type    = string
}
variable "resource_group_location" {
  default = ""
  type    = string
}
variable "kubernetes_cluster_id" {
  default = ""
  type    = string
}

## AZURE ACTIVE DIRECTORY CONFIGURATION VARIABLES

variable "client_id" {
  default = ""
  type    = string
}

variable "client_secret" {
  default = ""
  type    = string
}
variable "cluster_name" {
  default = ""
  type    = string
}

## AKS VARIABLES

variable "kubernetes_version" {
  default = ""
  type    = string
}

variable "admin_username" {
  default = ""
  type    = string
}

variable "public_ssh_key" {
  default = ""
  type    = string
}

variable "sku_tier" {
  default = ""
  type    = string
}

variable "private_cluster_enabled" {
  default = false
  type    = bool
}

variable "enable_http_application_routing" {
  default = false
  type    = bool
}


variable "enable_kube_dashboard" {
  default = false
  type    = bool
}

variable "balance_similar_node_groups" {
  default = true
  type    = bool
}

variable "max_graceful_termination_sec" {
  default = 600
  type    = number
}

variable "scale_down_delay_after_add" {
  default = "10m"
  type    = string
}

variable "scale_down_delay_after_delete" {
  default = "10s"
  type    = string
}

variable "scale_down_delay_after_failure" {
  default = "3m"
  type    = string
}

variable "scan_interval" {
  default = "10s"
  type    = string
}

variable "scale_down_unneeded" {
  default = "10m"
  type    = string
}

variable "scale_down_unready" {
  default = "20m"
  type    = string
}

variable "scale_down_utilization_threshold" {
  default = 0.5
  type    = number
}

variable "agents_pool_name" {
  default = [""]
  type    = list(string)
}

variable "agents_count" {
  default = 2
  type    = number
}

variable "agents_min_count" {
  default = 1
  type    = number
}

variable "agents_max_count" {
  default = 3
  type    = number
}

variable "agents_size" {
  default = [""]
  type    = list(string)
}

variable "node_taints" {
  default = [""]
  type    = list(string)
}
variable "subnet_id" {
  default = [""]
  type    = list(string)
}

variable "os_disk_size_gb" {
  default = 20
  type    = number
}

variable "enable_auto_scaling" {
  default = false
  type    = bool
}

variable "enable_node_public_ip" {
  default = true
  type    = bool
}

variable "agents_availability_zones" {
  default = null
  type    = list(string)
}

variable "agents_type" {
  default = ""
  type    = string
}

variable "agents_max_pods" {
  default = 50
  type    = number
}

variable "network_plugin" {
  default = ""
  type    = string
}


variable "net_profile_dns_service_ip" {
  default = ""
  type    = string
}

variable "net_profile_docker_bridge_cidr" {
  default = ""
  type    = string
}

variable "net_profile_outbound_type" {
  default = ""
  type    = string
}

variable "net_profile_pod_cidr" {
  default = ""
  type    = string
}

variable "net_profile_service_cidr" {
  default = ""
  type    = string
}

variable "node_pool" {
  default = {}
  type    = any
}

variable "rbac_enabled" {
  default = false
  type    = bool
}