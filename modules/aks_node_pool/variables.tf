## AKS VARIABLES

variable "kubernetes_version" {
  default = ""
  type    = string
}

variable "subnet_id" {
  default = [""]
  type    = list(string)
}

variable "node_pool" {
  default = {}
  type    = any
}
variable "enable_auto_scaling" {
  default = false
  type    = bool
}
variable "enable_node_public_ip" {
  default = true
  type    = bool
}
variable "kubernetes_cluster_id" {
  default = ""
  type    = string
}