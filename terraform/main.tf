terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstate6425"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# =========================
# EXISTING RESOURCE GROUP
# =========================
data "azurerm_resource_group" "rg" {
  name = "corp-dev-rg"
}

# =========================
# EXISTING LOG ANALYTICS
# =========================
data "azurerm_log_analytics_workspace" "law" {
  name                = "corp-dev-law"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# =========================
# OUTPUTS (for verification)
# =========================
output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "log_analytics_workspace_name" {
  value = data.azurerm_log_analytics_workspace.law.name
}

output "log_analytics_workspace_id" {
  value = data.azurerm_log_analytics_workspace.law.id
}


resource "azurerm_sentinel_alert_rule_scheduled" "rule1" {
  name                       = "suspicious-activity-rule"
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  display_name               = "Suspicious Activity Rule"
  severity                   = "Medium"

  query = <<QUERY
SecurityEvent
| take 5
QUERY

  query_frequency  = "PT5M"
  query_period     = "PT5M"
  trigger_operator = "GreaterThan"
  trigger_threshold = 0
  enabled          = true
}
