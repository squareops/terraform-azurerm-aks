resource "azurerm_kubernetes_cluster" "aks_cluster" {

  name                              = format("%s-%s", var.environment, var.name)
  location                          = var.resource_group_location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = format("%s-%s", var.environment, var.name)
  kubernetes_version                = var.kubernetes_version
  private_cluster_enabled           = var.private_cluster_enabled
  sku_tier                          = var.sku_tier
  role_based_access_control_enabled = var.rbac_enabled

  auto_scaler_profile {
    balance_similar_node_groups      = var.balance_similar_node_groups
    max_graceful_termination_sec     = var.max_graceful_termination_sec
    scale_down_delay_after_add       = var.scale_down_delay_after_add
    scale_down_delay_after_delete    = var.scale_down_delay_after_delete
    scale_down_delay_after_failure   = var.scale_down_delay_after_failure
    scan_interval                    = var.scan_interval
    scale_down_unneeded              = var.scale_down_unneeded
    scale_down_unready               = var.scale_down_unready
    scale_down_utilization_threshold = var.scale_down_utilization_threshold
  }

  dynamic "service_principal" {
    for_each = var.client_id != "" && var.client_secret != "" ? ["service_principal"] : []
    content {
      client_id     = var.client_id
      client_secret = var.client_secret
    }
  }

  identity {
    type           = "UserAssigned"
    identity_ids   = [var.user_assigned_identity_id]
  }

  default_node_pool {
    orchestrator_version  = var.kubernetes_version
    name                  = var.agents_pool_name[0]
    node_count            = var.agents_count
    vm_size               = var.agents_size[0]
    os_disk_size_gb       = var.os_disk_size_gb
    vnet_subnet_id        = var.subnet_id[0]
    enable_auto_scaling   = var.enable_auto_scaling
    min_count             = var.enable_auto_scaling ? var.agents_min_count : null
    max_count             = var.enable_auto_scaling ? var.agents_max_count : null
    enable_node_public_ip = var.enable_node_public_ip
    zones                 = var.agents_availability_zones
    type                  = var.agents_type
    max_pods              = var.agents_max_pods

    node_labels = {
      Infra-Services = "true"
    }

    tags = {
      "agent_pool_name" = var.agents_pool_name[0]
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    dns_service_ip     = var.net_profile_dns_service_ip
    docker_bridge_cidr = var.net_profile_docker_bridge_cidr
    outbound_type      = var.net_profile_outbound_type
    pod_cidr           = var.network_plugin == "kubenet" ? var.net_profile_pod_cidr : null
    service_cidr       = var.net_profile_service_cidr
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
        key_data = var.public_ssh_key
    }
  }

  tags = {
    "Name" = format("%s-%s", var.environment, var.name)
  }

  lifecycle {
    ignore_changes = [
      default_node_pool.0.node_count
    ]
  }
}
resource "azurerm_kubernetes_cluster_node_pool" "node_pool"  {
    name                  = var.agents_pool_name[1]
    node_count            = var.agents_count
    vm_size               = var.agents_size[1]
    vnet_subnet_id        = var.subnet_id[0]
    enable_auto_scaling   = var.enable_auto_scaling
    min_count             = var.enable_auto_scaling ? var.agents_min_count : null
    max_count             = var.enable_auto_scaling ? var.agents_max_count : null
    enable_node_public_ip = var.enable_node_public_ip
    kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
    zones                 = var.agents_availability_zones
    max_pods              = var.agents_max_pods
    node_labels = {
      App-Services = "true"
    }
    tags = {
      "agent_pool_name" = var.agents_pool_name[1]
    }
  }

resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "logs" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${azurerm_kubernetes_cluster.aks_cluster.name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_workspace_sku
  tags                = var.additional_tags
}

resource "azurerm_log_analytics_solution" "logs" {
  count                 = var.enable_log_analytics_solution ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.logs.id
  workspace_name        = azurerm_log_analytics_workspace.logs.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = var.additional_tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "control_plane" {
  count                      = var.enable_control_plane_logs_scrape ? 1 : 0
  name                       = var.control_plane_monitor_name
  target_resource_id         = azurerm_kubernetes_cluster.aks_cluster.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  enabled_log {
    category = "cloud-controller-manager"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "cluster-autoscaler"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "csi-azuredisk-controller"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "csi-azurefile-controller"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "csi-snapshot-controller"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "kube-apiserver"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "kube-controller-manager"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  enabled_log {
    category = "kube-scheduler"

    retention_policy {
      enabled = true
      days    = 7
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      enabled = false
      days    = 0
    }
  }
}