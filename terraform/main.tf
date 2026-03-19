provider "azurerm" {
  features {}
}

# Existing Resource Group
data "azurerm_resource_group" "rg" {
  name = "corp-dev-rg"
}

# Existing VNet
data "azurerm_virtual_network" "vnet" {
  name                = "corp-dev-vnet"
  resource_group_name = "corp-dev-rg"
}

# Existing Subnet
data "azurerm_subnet" "subnet" {
  name                 = "corp-dev-subnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

data "azurerm_log_analytics_workspace" "law" {
  name                = "corp-dev-law"
  resource_group_name = "corp-dev-rg"
}
