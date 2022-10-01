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
  name     = "ff-email-updates-resource-group"
  location = var.region
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "ffemailupdatesstorage"
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "application_insights" {
  name                = "ff-email-updates-application-insights"
  location            = var.region
  resource_group_name = azurerm_resource_group.resource_group.name
  application_type    = "web"
}

resource "azurerm_service_plan" "service_plan" {
  name                = "ff-email-updates-service-plan"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.region
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_communication_service" "ff_email_updates" {
  name                = "ff-email-messages"
  resource_group_name = azurerm_resource_group.resource_group.name
  data_location       = "United States"
}

resource "azurerm_linux_function_app" "ff_email_updates_app" {
  name                = "ff-email-updates"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.region

  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.service_plan.id

  app_settings = {
    LEAGUE_ID = var.league_id
    EMAIL = var.email
    SWID = var.swid
    ESPN_S2 = var.espn_s2
    INTERVAL = var.interval
    EMAIL_DOMAIN = var.azure_email_domain
    CONNECTION_STRING = azurerm_communication_service.ff_email_updates.primary_connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.application_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.application_insights.connection_string
    WEBSITE_RUN_FROM_PACKAGE = 1
  }

  site_config {
    application_stack {
        python_version = "3.9"
    }
  }
}