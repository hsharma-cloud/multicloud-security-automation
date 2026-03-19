provider "azurerm" {
  features {}
}

# EXISTING RESOURCE GROUP
data "azurerm_resource_group" "rg" {
  name = "corp-dev-rg"
}

# EXISTING VNET
data "azurerm_virtual_network" "vnet" {
  name                = "corp-dev-vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# CREATE SUBNET (safe)
resource "azurerm_subnet" "subnet" {
  name                 = "corp-dev-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "corp-dev-aks"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "corpdevaks"

  default_node_pool {
    name           = "nodepool1"
    node_count     = 1
    vm_size        = "Standard_DC2s_v3"
    vnet_subnet_id = azurerm_subnet.subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}
