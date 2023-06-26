# Terraform provider

provider "azurerm" {
  features {
     resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Kubernetes provider

provider "kubernetes" {
  host                   = "${module.aks_cluster.host}"
  client_certificate     = "${module.aks_cluster.client_certificate}"
  client_key             = "${module.aks_cluster.client_key}"
  cluster_ca_certificate = "${module.aks_cluster.cluster_ca_certificate}"
  config_path = "~/.kube/config"
}

# Helm provider

provider "helm" {
  kubernetes {
      host                   = "${module.aks_cluster.host}"
      client_certificate     = "${module.aks_cluster.client_certificate}"
      client_key             = "${module.aks_cluster.client_key}"
      cluster_ca_certificate = "${module.aks_cluster.cluster_ca_certificate}"
      config_path = "~/.kube/config"
  }
}