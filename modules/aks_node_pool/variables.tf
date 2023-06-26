## AKS VARIABLES

variable "kubernetes_version" {
  default = ""
  type    = string
  description = "The version of Kubernetes to use in the AKS cluster."
}

variable "subnet_id" {
  default = [""]
  type    = list(string)
  description = "The IDs of the subnets where the AKS cluster will be deployed."
}

variable "node_pool" {
  default = {}
  type    = any
  description = "The configuration for the node pool in the AKS cluster."
}

variable "enable_auto_scaling" {
  default = false
  type    = bool
  description = "Enables or disables auto-scaling of the AKS cluster nodes."
}

variable "enable_node_public_ip" {
  default = true
  type    = bool
  description = "Indicates whether nodes in the AKS cluster have public IP addresses."
}

variable "kubernetes_cluster_id" {
  default = ""
  type    = string
  description = "The ID of the Kubernetes cluster (e.g., AKS cluster ID)."
}
