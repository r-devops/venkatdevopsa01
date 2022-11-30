
# Create a resource group
resource "azurerm_resource_group" "tfautomation" {
  name     = "Azure-trainings"
  location = "South India"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "tfautomation" {
  name                = "tfautomation-network"
  resource_group_name = azurerm_resource_group.tfautomation.name
  location            = azurerm_resource_group.tfautomation.location
  address_space       = ["10.10.0.0/16"]
}