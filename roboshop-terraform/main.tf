
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

resource "azurerm_network_interface" "tfautomation" {
  name                = "devvm01-nic"
  location            = azurerm_resource_group.tfautomation.location
  resource_group_name = azurerm_resource_group.tfautomation.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tfautomation.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tfautomation.id
  }
}




resource "azurerm_linux_virtual_machine" "tfautomation" {
  name                = "devvm01"
  resource_group_name = azurerm_resource_group.tfautomation.name
  location            = azurerm_resource_group.tfautomation.location
  size                = "Standard_B1ls"
  admin_username      = "centos"
  admin_password      = "DevOps654321"
  network_interface_ids = [
    azurerm_network_interface.tfautomation.id,
  ]

 disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9-gen2"
    version   = "latest"
  }
}