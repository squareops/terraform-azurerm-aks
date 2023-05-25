#!/bin/bash

kubectl delete svc ingress-nginx-controller-controller -n ingress-nginx
terraform state rm kubernetes_namespace.cert_manager kubernetes_namespace.ingress_nginx[0] data.kubernetes_service.get_ingress_nginx_controller_svc[0]
# terraform destroy -var-file=existing_vpc.tfvars -auto-approve
# terraform destroy -var-file=new_vpc.tfvars -auto-approve