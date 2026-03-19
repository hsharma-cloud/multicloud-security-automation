provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "corp-dev-rg"
  location = "eastus"
}
resource "azurerm_security_center_subscription_pricing" "defender" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}
