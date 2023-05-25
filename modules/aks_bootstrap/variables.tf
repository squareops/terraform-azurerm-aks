variable "resource_group_name" {
  default = ""
  type    = string
}
variable "resource_group_location" {
  default = ""
  type    = string
}
variable "network_plugin" {
  default = ""
  type    = string
}
variable "cluster_name" {
  default = ""
  type    = string
}
variable "cert_manager_version" {
  default = ""
  type    = string
}
variable "cert_manager_enabled" {
  default = false
  type    = bool
}

## NGINX INGRESS

variable "ingress_nginx_enabled" {
  default = false
  type    = bool
}

variable "ingress_nginx_version" {
  default = ""
  type    = string
}