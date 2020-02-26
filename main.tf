resource "azurerm_resource_group" "mon_premier_resource_group" {
  name =     "${var.name}"
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
  name     = ""
  location = ""
  resource_group_name = ""
  
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
    direction                  = "Inbound
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*" 
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
