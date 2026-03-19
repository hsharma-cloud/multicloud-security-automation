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

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = data.azurerm_log_analytics_workspace.law.id
}

resource "azurerm_sentinel_alert_rule_scheduled" "test_rule" {
  name                       = "test-alert-rule"
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  display_name               = "Test Alert Rule"
  severity                   = "Medium"
  query                      = <<QUERY
SecurityEvent
| take 5
QUERY
  query_frequency            = "PT5M"
  query_period               = "PT5M"
  trigger_operator           = "GreaterThan"
  trigger_threshold          = 0
  enabled                    = true
}
