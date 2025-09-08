resource "azurerm_resource_group" "aks" {
    name     = "${var.resource_group_name}"
    location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.location
  address_space       = var.address_space #["10.1.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 =  var.subnet_name#"aksnodes"
  resource_group_name  = var.resource_group_name
  address_prefixes     = var.address_prefixes
  virtual_network_name = var.virtual_network_name
}


resource "azurerm_kubernetes_cluster" "aks" {
    name                = var.cluster_name
    location            = var.location
    resource_group_name = var.resource_group_name
    dns_prefix          = "${var.dns_prefix}"
    kubernetes_version  = "${var.kubernetes_version}"
  default_node_pool {name = ""}

    linux_profile {
        admin_username = "azureuser"

        ssh_key {
            key_data = "${file("${var.ssh_public_key}")}"
        }
    }

    agent_pool_profile {
        name            = "agentpool"
        count           = "${var.agent_count}"
        vm_size         = "Standard_DS2_v2"
        os_type         = "Linux"
        os_disk_size_gb = 30

        vnet_subnet_id = "${azurerm_subnet.subnet.id}"
    }

    service_principal {
        client_id     = "${var.client_id}"
        client_secret = "${var.client_secret}"
    }

    network_profile {
        network_plugin = "${var.network_plugin}"
    }

    role_based_access_control {
        enabled = true
    }

    tags {
        Environment = "Development"
    }

    provisioner "local-exec" {
        command = "./helm-install.sh"

        environment {
            AKS_NAME = "${var.cluster_name}"
            AKS_RG   = "${var.resource_group_name}"
        }
    }
}

data "azuread_service_principal" "akssp" {
  application_id = "${var.client_id}"
}

resource "azurerm_role_assignment" "netcontribrole" {
  scope                = "${azurerm_subnet.subnet.id}"
  role_definition_name = "Network Contributor"
  principal_id         = "${data.azuread_service_principal.akssp.object_id}"
}
