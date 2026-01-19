variable "prefix" {
  default = "tfvmex"
}
##Resouce Group
resource "azurerm_resource_group" "MyfirstprojectV2" {
  name     = "MyfirstprojectV2"
  location = "Central India"
}
##virtual_network
resource "azurerm_virtual_network" "main" {
  name                = "MyfirstprojectV2_network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.MyfirstprojectV2.location
  resource_group_name = azurerm_resource_group.MyfirstprojectV2.name
}
##Subnet
resource "azurerm_subnet" "internal" {
  name                 = "MyfirstprojectV2_subnet1"
  resource_group_name  = azurerm_resource_group.MyfirstprojectV2.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}
##Network Interface
resource "azurerm_network_interface" "main" {
  name                = "MyfirstprojectV2-nic"
  location            = azurerm_resource_group.MyfirstprojectV2.location
  resource_group_name = azurerm_resource_group.MyfirstprojectV2.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}
##Virtual Machine
resource "azurerm_linux_virtual_machine" "MyfirstprojectV2" {
  name                = "MyfirstprojectV2-VM"
  resource_group_name = azurerm_resource_group.MyfirstprojectV2.name
  location            = azurerm_resource_group.MyfirstprojectV2.location
  size                = "Standard_B2ats_V2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("C:/Users/rashn/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}