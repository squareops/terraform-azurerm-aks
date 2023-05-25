variable "subnet_prefixes" {
  default = ["", "", ""]
  type    = list(string)
}

variable "subnet_names" {
  default = ["", "", ""]
  type    = list(string)
}
variable "resource_group_name" {
  default = ""
  type    = string
}
variable "resource_group_location" {
  default = ""
  type    = string
}
variable "vnet_subnets" {
  default = ["", "", ""]
  type    = list(string)
}