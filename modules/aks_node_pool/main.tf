resource "azurerm_kubernetes_cluster_node_pool" "aks_node_pool" {
  for_each =  var.node_pool
  name                  = lookup(each.value, "name", null)
  kubernetes_cluster_id = var.kubernetes_cluster_id
  vm_size               = lookup(each.value, "vm_size", null)
  zones                 = lookup(each.value, "availability_zones", null)
  enable_auto_scaling   = var.enable_auto_scaling
  max_count             = lookup(each.value, "max_count", null)
  min_count             = lookup(each.value, "min_count", null)
  node_count            = lookup(each.value, "node_count", null)
  enable_node_public_ip = var.enable_node_public_ip
  eviction_policy       = lookup(each.value, "priority", null) == "Spot" ? lookup(each.value, "eviction_policy", null) : null
  max_pods              = lookup(each.value, "max_pods", null)
  mode                  = lookup(each.value, "mode", null)
  node_labels           = lookup(each.value, "node_labels", null)
  node_taints           = lookup(each.value, "node_taints", null)
  orchestrator_version  = var.kubernetes_version
  os_disk_size_gb       = lookup(each.value, "os_disk_size_gb", null)
  os_disk_type          = "Managed"
  os_type               = "Linux"
  priority              = lookup(each.value, "priority", null)
  spot_max_price        = lookup(each.value, "priority", null) == "Spot" ? lookup(each.value, "spot_max_price", null) : null
  vnet_subnet_id        = var.subnet_id[0]
}