terraform {
  backend "azurerm" {
    resource_group_name  = "skaf-test-rg"
    storage_account_name = "skaftest"
    container_name       = "skaf-test-sc"
    key                  = "skaf-terraform-infra/aks.tfstate"
  }
}