output "subnet_id" {
  description = "Subnet ID"
  value       = azurerm_subnet_network_security_group_association.subnet_network_sg_association.*.id
}