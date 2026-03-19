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

# NEW: Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "corp-dev-law"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
