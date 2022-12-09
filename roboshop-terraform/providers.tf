terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = "d8391944-774c-41db-95d3-6797158258bc"
  client_id       = "b81b4bb4-fb1d-4018-8f5c-b507d309b72d"
  client_secret   = var.client_secret
  tenant_id       = "ecfdc663-dd83-47ef-980b-636e9e2ae30b"

}


variable "client_secret" {
  default     = " "
  description = "password to login to Azure"
}

