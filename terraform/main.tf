terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
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
