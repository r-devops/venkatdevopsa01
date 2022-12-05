
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

# Create subnet
resource "azurerm_subnet" "tfautomation" {
  name                 = "tfautomation-subnet"
  resource_group_name  = azurerm_resource_group.tfautomation.name
  virtual_network_name = azurerm_virtual_network.tfautomation.name
  address_prefixes     = ["10.10.1.0/24"]
}

output "subnet_id" {
  description = "Subnet ID"
  value       = azurerm_subnet.tfautomation.id
}



# Create Network Security Group and rule
resource "azurerm_network_security_group" "tfautomation" {
  name                = "tfautomation-nsg"
  location            = azurerm_resource_group.tfautomation.location
  resource_group_name = azurerm_resource_group.tfautomation.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "Port8080"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


}




resource "azurerm_public_ip" "tfautomation" {
  name                = "tf-PublicIp1"
  resource_group_name = azurerm_resource_group.tfautomation.name
  location            = azurerm_resource_group.tfautomation.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}



module "linuxservers" {
  source                    = "./module-vm"
  for_each                  = toset(var.vm_name)
  vm_name                   = each.value
  network_interface_name    = "${each.value}-nic"
  location                  = azurerm_resource_group.tfautomation.location
  rg_name                   = azurerm_resource_group.tfautomation.name
  subnet_id                 = azurerm_subnet.tfautomation.id 

  depends_on = [azurerm_virtual_network.tfautomation]
}

