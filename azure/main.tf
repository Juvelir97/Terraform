# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

variable "prefix" {
  default = "xxx"
}
variable "myip"{
  
}
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.interview4-rg.location
  resource_group_name = azurerm_resource_group.interview4-rg.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "main"{

  name           = "subnet1"
  #location            = azurerm_resource_group.interview4-rg.location
   virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name = azurerm_resource_group.interview4-rg.name
  address_prefixes = ["10.0.1.0/24"]
  #security_group = azurerm_network_security_group.example.id
  }


resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.interview4-rg.location
  resource_group_name = azurerm_resource_group.interview4-rg.name
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.interview4-rg.location
  resource_group_name = azurerm_resource_group.interview4-rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
}


resource "azurerm_network_security_group" "mysecgroup" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.interview4-rg.location
  resource_group_name = azurerm_resource_group.interview4-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.myip
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.mysecgroup.id
}

resource "tls_private_key" "my_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "myvm" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.interview4-rg.location
  resource_group_name   = azurerm_resource_group.interview4-rg.name
  network_interface_ids = [azurerm_network_interface.main.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.my_ssh.public_key_openssh
  }
}
