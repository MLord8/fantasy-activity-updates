terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~> 3.24.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name = "ff-sms-updates-resource-group"
  location = var.region
}

resource "azurerm_storage_account" "storage_account" {
  name = "ff_sms_updates_storage"
  resource_group_name = azurerm_resource_group.resource_group.name
  location = var.region
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "service_plan" {
  name                = "ff-sms-updates-service-plan"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.region
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_communication_service" "ff_sms_messages" {
  name                = "ff-sms-messages"
  resource_group_name = azurerm_resource_group.resource_group.name
  data_location       = "United States"
}

resource "azurerm_linux_function_app" "example" {
  name                = "ff-sms-updates"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.region

  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.service_plan.id

  app_settings = {
    "LEAGUE_ID" = var.league_id
    "SMS_NUMBER" = var.sms_number
    "CONNECTION_STRING" = azurerm_communication_service.ff_sms_messages.primary_connection_string
  }

  site_config {}
}