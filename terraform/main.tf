provider "azurerm" {
  features {}
}

# -------------------------------
# EXISTING RESOURCE GROUP
# -------------------------------
data "azurerm_resource_group" "rg" {
  name = "corp-dev-rg"
}

# -------------------------------
# EXISTING VIRTUAL NETWORK
# -------------------------------
data "azurerm_virtual_network" "vnet" {
  name                = "corp-dev-vnet"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# -------------------------------
# EXISTING SUBNET
# -------------------------------
data "azurerm_subnet" "subnet" {
  name                 = "corp-dev-subnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

# -------------------------------
# AKS CLUSTER (ONLY RESOURCE CREATED)
# -------------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "corp-dev-aks"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "corpdevaks"

  default_node_pool {
    name           = "nodepool1"
    node_count     = 1
    vm_size        = "Standard_DC2s_v3"   # ✅ allowed in your subscription
    vnet_subnet_id = data.azurerm_subnet.subnet.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}
