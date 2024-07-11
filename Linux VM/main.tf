# Azure Provider 
provider "azurerm" {
  features {}
}
# Create a resource group 
resource "azurerm_resource_group" "myrg" {
  name = var.resource_group_name
  location = var.location
}
# Create a Virtual Network
resource "azurerm_virtual_network" "myvnet" {
  name = var.virtual_network_name
  location = var.location
  resource_group_name = azurerm_resource_group.myrg.name
  address_space = ["10.0.0.0/16"]
}
# Create a subnet
resource "azurerm_subnet" "mysubnet" {
  name = var.subnet_name
  resource_group_name = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes = ["10.0.1.0/24"]
}
# Create multiple public Ip addresses using count
resource "azurerm_public_ip" "mypuip" {
    count = 3
    name = "publicip-${count.index}"
    resource_group_name = azurerm_resource_group.myrg.name
    location = var.location
    allocation_method = "Dynamic" 
}
#Create multiple Network interfaces using count
resource "azurerm_network_interface" "mynic" {
    count = 3
    name = "mynic-${count.index}"
    resource_group_name = azurerm_resource_group.myrg.name
    location = var.location
    ip_configuration {
      name = "myip"
      private_ip_address = "10.0.1.0${count.index}"
      private_ip_address_allocation = "Dynamic"
      subnet_id = azurerm_subnet.mysubnet.id
      public_ip_address_id = azurerm_public_ip.mypuip[count.index].id
    }
}
# Create Multiple Linux Virtual machines using count
resource "azurerm_linux_virtual_machine" "myvm" {
    count = 3
    name              = "myvm-${count.index}"
    resource_group_name = azurerm_resource_group.myrg.name
    location            = var.location
    size                = var.VM_Size
    disable_password_authentication = false
   admin_username      = var.admin_username
   admin_password = var.admin_password
   network_interface_ids = [
    azurerm_network_interface.mynic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = "Latest"
  }
}