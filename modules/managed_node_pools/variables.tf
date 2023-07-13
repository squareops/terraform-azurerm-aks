
# Docs
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool
variable "node_pools" {}

variable "resource_group_name" {
  type    = string
  default = ""
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "kubernetes_cluster_id" {
  type     = string
  default  = ""
}

variable "vnet_subnet_id" {
  type    = list(string)
  default = [""]
}

variable "orchestrator_version" {
  description = "Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region"
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Any tags can be set"
  default     = {}
}