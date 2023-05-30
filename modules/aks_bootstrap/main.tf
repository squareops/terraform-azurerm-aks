resource "null_resource" "get_kubeconfig" {

  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${var.resource_group_name} --name ${var.cluster_name} --admin --overwrite-existing"
  }
}
resource "kubernetes_namespace" "cert_manager" {
  count      = var.cert_manager_enabled ? 1 : 0
  depends_on = [null_resource.get_kubeconfig]

  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "ingress_nginx" {
  count      = var.ingress_nginx_enabled ? 1 : 0
  depends_on = [null_resource.get_kubeconfig]

  metadata {
    name = "ingress-nginx"
  }
}

resource "null_resource" "aks_custom_storage_class" {
  depends_on = [null_resource.get_kubeconfig]


  provisioner "local-exec" {
    command = "kubectl apply -f ../../files/aks-custom-storage-class.yaml"
  }
}
resource "helm_release" "ingress_nginx_controller" {
  count      = var.ingress_nginx_enabled ? 1 : 0
  depends_on = [kubernetes_namespace.ingress_nginx]

  name       = "ingress-nginx-controller"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  dependency_update = true
  reset_values      = true
  atomic            = true
  replace           = true
  version    = var.ingress_nginx_version
  timeout    = 600

  values = [
    file("../../helm/ingress-nginx-controller/values.yaml")
  ]
  lifecycle {
    create_before_destroy = true
    }
}
resource "null_resource" "jetstack" {
  count      = var.cert_manager_enabled ? 1 : 0
  depends_on = [kubernetes_namespace.cert_manager]

  provisioner "local-exec" {
    command = "kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v${var.cert_manager_version}/cert-manager.crds.yaml"
  }
}

resource "helm_release" "cert_manager" {
  count      = var.cert_manager_enabled ? 1 : 0
  depends_on = [null_resource.jetstack]

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  dependency_update = true
  reset_values      = true
  atomic            = true
  replace           = true
  version    = format("%s%s", "v", var.cert_manager_version)
  timeout    = 600

  values = [
    file("../../helm/cert-manager/values.yaml")
  ]
  lifecycle {
    create_before_destroy = true
    }
}
resource "null_resource" "cluster_issuer" {
  depends_on = [helm_release.cert_manager]
  count      = var.cert_manager_enabled ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl apply -f ../../helm/production-issuer/prod-issuer.yaml"
  }
}
data "kubernetes_service" "get_ingress_nginx_controller_svc" {
  count      = var.ingress_nginx_enabled ? 1 : 0
  depends_on = [helm_release.ingress_nginx_controller]

  metadata {
    name      = "ingress-nginx-controller-controller"
    namespace = "ingress-nginx"
  }
}
output "nginx_ingress_controller_external_ip" {
  description = "NGINX Ingress Controller External IP"
  value       = join("", data.kubernetes_service.get_ingress_nginx_controller_svc.*.status.0.load_balancer.0.ingress.0.ip)
}