terraform {
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">=4.0.0"
    }
  }

  #required_version = ">= 1.5.0"
}

provider "azurerm" {

    features {
      
    }
  subscription_id = "614aaa17-a839-4de6-a183-ea1c0b183504"
}

#provider "azurerm" {
#  features {}
 # subscription_id = "614aaa17-a839-4de6-a183-ea1c0b183504"
#}

module "azurerm_kubernetes_cluster" {
  source = "../resources/aks"
  cluster_name = var.cluster_name
  resource_group_name = var.resource_group_name
  location = var.location
  kubernetes_version = var.kubernetes_version
  pool_name = var.pool_name
  node_count = var.node_count
  virtual_network_name = var.virtual_network_name
  subnet_name = var.subnet_name
  vm_size = var.vm_size
  address_prefixes = var.address_prefixes
  dns_prefix = var.dns_prefix
  address_space = var.address_space

}
