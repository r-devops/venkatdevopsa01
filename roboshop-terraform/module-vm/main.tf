
resource "azurerm_network_interface" "tfautomation" {
  name                = var.network_interface_name
  location            = var.location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}




resource "azurerm_linux_virtual_machine" "tfautomation" {
  name                = var.vm_name
  resource_group_name = var.rg_name
  location            = var.location
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