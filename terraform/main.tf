provider "azurerm" {
  features {}
}

# Use existing Resource Group
data "azurerm_resource_group" "rg" {
  name = "corp-dev-rg"
}

# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "corp-dev-vnet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}
