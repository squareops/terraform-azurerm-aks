module "resource-group" {
  source                  = "./modules/resource-group"
  count                   = var.create_resource_group ? 1 : 0
  resource_group_name     = format("%s-%s-aks-resource-group", var.environment, var.name)
  resource_group_location = var.resource_group_location
  tags                    = var.tags
}

data "azurerm_subscription" "primary" {}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Network Contributor"
  principal_id         = var.principal_id
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                              = format("%s-%s", var.environment, var.name)
  location                          = var.resource_group_location
  resource_group_name               = var.create_resource_group == false ? var.existing_resource_group_name : module.resource-group[0].resource_group_name
  dns_prefix                        = format("%s-%s", var.environment, var.name)
  kubernetes_version                = var.kubernetes_version
  private_cluster_enabled           = var.private_cluster_enabled
  sku_tier                          = var.sku_tier
  role_based_access_control_enabled = var.rbac_enabled
  oidc_issuer_enabled               = var.oidc_issuer_enabled

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
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  default_node_pool {
    orchestrator_version   = var.kubernetes_version
    name                   = var.default_agent_pool_name
    node_count             = var.default_agent_pool_count
    vm_size                = var.default_agent_pool_size
    os_disk_size_gb        = var.os_disk_size_gb
    vnet_subnet_id         = var.subnet_id[0]
    enable_auto_scaling    = var.auto_scaling_enabled
    min_count              = var.auto_scaling_enabled ? var.agents_min_count : null
    max_count              = var.auto_scaling_enabled ? var.agents_max_count : null
    enable_node_public_ip  = var.node_public_ip_enabled
    zones                  = var.agents_availability_zones
    type                   = var.agents_type
    node_labels            = var.default_node_labels
    enable_host_encryption = var.host_encryption_enabled
    tags = {
      "agent_pool_name" = var.default_agent_pool_name
    }
  }

  network_profile {
    network_plugin     = var.network_plugin
    dns_service_ip     = var.net_profile_dns_service_ip
    outbound_type      = var.net_profile_outbound_type
    docker_bridge_cidr = var.net_profile_docker_bridge_cidr
    pod_cidr           = var.network_plugin == "kubenet" ? var.net_profile_pod_cidr : null
    service_cidr       = var.net_profile_service_cidr
    network_policy     = var.network_plugin == "kubenet" ? "calico" : var.network_plugin == "azure" ? "azure" : null
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

resource "null_resource" "open_service_mesh_addon" {
  count = var.open_service_mesh_enabled ? 1 : 0
  provisioner "local-exec" {
    command = var.open_service_mesh_enabled ? "az aks enable-addons --resource-group ${azurerm_kubernetes_cluster.aks_cluster.resource_group_name} --name ${azurerm_kubernetes_cluster.aks_cluster.name} --addons open-service-mesh" : "az aks disable-addons --resource-group ${azurerm_kubernetes_cluster.aks_cluster.resource_group_name} --name ${azurerm_kubernetes_cluster.aks_cluster.name} --addons open-service-mesh"
  }
}

resource "random_id" "log_analytics_workspace_name_suffix" {
  byte_length = 8
}

resource "azurerm_log_analytics_workspace" "logs" {
  # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
  name                = "${azurerm_kubernetes_cluster.aks_cluster.name}-${random_id.log_analytics_workspace_name_suffix.dec}"
  location            = var.resource_group_location
  resource_group_name = var.create_resource_group == false ? var.existing_resource_group_name : module.resource-group[0].resource_group_name
  sku                 = var.log_analytics_workspace_sku
  tags                = var.additional_tags
}

resource "azurerm_log_analytics_solution" "logs" {
  count                 = var.log_analytics_solution_enabled ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = var.resource_group_location
  resource_group_name   = var.create_resource_group == false ? var.existing_resource_group_name : module.resource-group[0].resource_group_name
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
  count                      = var.control_plane_logs_scrape_enabled ? 1 : 0
  name                       = var.control_plane_monitor_name
  target_resource_id         = azurerm_kubernetes_cluster.aks_cluster.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs.id

  log {
    category = "cloud-controller-manager"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 7
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 7
    }
  }

  log {
    category = "csi-azuredisk-controller"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 7
    }
  }

  log {
    category = "csi-azurefile-controller"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 7
    }
  }

  log {
    category = "csi-snapshot-controller"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 7
    }
  }

  log {
    category = "kube-apiserver"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 7
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true
    retention_policy {
      enabled = true
      days    = 7
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = true
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
