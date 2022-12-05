
resource "azurerm_network_interface" "tfautomation" {
  count         = 2  
  name                = "devvm-nic-${count.index}"
  location            = azurerm_resource_group.tfautomation.location
  resource_group_name = azurerm_resource_group.tfautomation.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.tfautomation.id
    private_ip_address_allocation = "Dynamic"
   #public_ip_address_id          = azurerm_public_ip.tfautomation.id
  }
}




resource "azurerm_linux_virtual_machine" "tfautomation" {
  count         = 2
  name                = "devvm-${count.index}"
  resource_group_name = azurerm_resource_group.tfautomation.name
  location            = azurerm_resource_group.tfautomation.location
  size                = "Standard_B1ls"
  admin_username      = "centos"
  admin_password      = "DevOps654321"
  network_interface_ids = [
    azurerm_network_interface.tfautomation.*.id[count.index],
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