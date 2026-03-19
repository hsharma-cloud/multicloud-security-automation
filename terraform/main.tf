provider "azurerm" {
  features {}
}

# Existing Resource Group
data "azurerm_resource_group" "rg" {
  name = "corp-dev-rg"
}

# Existing Virtual Network
data "azurerm_virtual_network" "vnet" {
  name                = "corp-dev-vnet"
  resource_group_name = "corp-dev-rg"
}

# Create Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "corp-dev-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
