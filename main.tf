
resource "azurerm_resource_group" "mon_premier_resource_group" {
  name     = var.name
  location = "${var.location}"
  tags = {
    owner = "${var.owner}"
  }
}

resource "azurerm_virtual_network" "mon_premier_virtual_network" {
  name     = "${var.name_vnet}"
  address_space = "${var.address_space}"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.mon_premier_resource_group.name}" 
}

resource "azurerm_subnet" "mon_premier_subnet" {
  name                 = "${var.name_subnet}"   
  resource_group_name  = "${azurerm_resource_group.mon_premier_resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.mon_premier_virtual_network.name}"
  address_prefix       = "${var.address_prefix}"
}

resource "azurerm_network_security_group" "mon_premier_security_group" {
  name     = "${var.name_nsg}"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.mon_premier_resource_group.name}"
  
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
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
}

resource "azurerm_public_ip" "mon_premier_public_ip" {
  name                = "${var.name_public_ip}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.mon_premier_resource_group.name}"
  allocation_method  = "${var.allocation_method}"
}

resource "azurerm_network_interface" "mon_premier_network_interface" {
  name = "${var.name_network_interface}"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.mon_premier_resource_group.name}"
  network_security_group_id = "${azurerm_network_security_group.mon_premier_security_group.id}"
  ip_configuration {
    name = "${var.name_ip_config}"
    subnet_id = "${azurerm_subnet.mon_premier_subnet.id}"
    private_ip_address_allocation = "${var.allocation_method}"
    public_ip_address_id = "${azurerm_public_ip.mon_premier_public_ip.id}"
  }
}

resource "azurerm_virtual_machine" "ma_vm" {
  name       = "${var.name_vm}"
  location   = "${var.location}"
  resource_group_name = "${azurerm_resource_group.mon_premier_resource_group.name}"
  network_interface_ids = [ "${azurerm_network_interface.mon_premier_network_interface.id}" ]
  vm_size = "${var.vm_size}"
  
  storage_os_disk {
    name              = "mon_disque"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_image_reference {
    publisher = "OpenLogic"
    offer = "CentOS"
    sku = "7.6"
    version = "latest"
  } 
  os_profile {
    computer_name = "mabellevm"
    admin_username = "raph"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/raph/.ssh/authorized_keys"
      key_data = "${var.public_key}"
    }
  }
}



