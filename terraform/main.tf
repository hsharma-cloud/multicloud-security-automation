provider "azurerm" {
  features {}
}

# Use existing Resource Group (DO NOT recreate)
data "azurerm_resource_group" "rg" {
  name = "corp-dev-rg"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "corp-dev-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Subnet for AKS
resource "azurerm_subnet" "subnet" {
  name                 = "corp-dev-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "corp-dev-aks"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "corpdevaks"

  default_node_pool {
    name       = "nodepool1"
    node_count = 1
    vm_size    = "Standard_DC2s_v3"   # ✅ works in your subscription
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}
