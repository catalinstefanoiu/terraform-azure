# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "mtc-rg" {
  name     = "mtc-resources"
  location = "West Europe"
  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_network" "mtc-vn" {
  name                = "mtc-network"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    environment = "test"
  }
}

resource "azurerm_subnet" "mtc-subnet" {
  name                 = "mtc-subnet"
  resource_group_name  = azurerm_resource_group.mtc-rg.name
  virtual_network_name = azurerm_virtual_network.mtc-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

# resource "azurerm_network_security_group" "mtc-sg" {
#   name                = "mtc-sg"
#   location            = azurerm_resource_group.mtc-rg.location
#   resource_group_name = azurerm_resource_group.mtc-rg.name

#   tags = {
#     environment = "test"
#   }
# }

# resource "azurerm_network_security_rule" "mtc-dev-rule" {
#   name                        = "mtc-dev-rule"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "188.24.139.236/32"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.mtc-rg.name
#   network_security_group_name = azurerm_network_security_group.mtc-sg.name
# }

# resource "azurerm_subnet_network_security_group_association" "mtc-sga" {
#   subnet_id                 = azurerm_subnet.mtc-subnet.id
#   network_security_group_id = azurerm_network_security_group.mtc-sg.id
# }

resource "azurerm_public_ip" "mtc-ip" {
  count               = var.vm_count
  name                = "mtc-ip-${count.index + 1}"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "test"
  }
}

resource "azurerm_network_interface" "mtc-nic" {
  count               = var.vm_count
  name                = "mtc-nic-${count.index + 1}"
  location            = azurerm_resource_group.mtc-rg.location
  resource_group_name = azurerm_resource_group.mtc-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mtc-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mtc-ip[count.index].id
  }

  tags = {
    environment = "test"
  }
}

resource "random_password" "vm_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_linux_virtual_machine" "mtc-vm" {
  count               = var.vm_count
  name                = "mtc-vm-${count.index + 1}"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  size                = var.vm_size
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.mtc-nic[count.index].id,
  ]

  admin_password = random_password.vm_password.result

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/mtcazureke.pub")
  }

  #   custom_data = filebase64("customdata.tpl")

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = var.vm_image
    version   = "latest"
  }

  # provisioner "local-exec" {
  #   command = templatefile("${var.host_os}-ssh-script.tpl", {
  #     hostname     = self.public_ip_address,
  #     user         = "adminuser",
  #     identityfile = "~/.ssh/mtcazureke"
  #   })
  #   interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  # }

  tags = {
    environment = "test"
  }
}

data "azurerm_public_ip" "mtc-ip-data" {
  count               = var.vm_count
  name                = azurerm_public_ip.mtc-ip[count.index].name
  resource_group_name = azurerm_resource_group.mtc-rg.name
}

resource "null_resource" "test-ping" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.mtc-ip[0].ip_address
      user        = "adminuser"
      private_key = file("~/.ssh/mtcazureke")
    }

    inline = [
      "ping -c 4 ${azurerm_network_interface.mtc-nic[1].private_ip_address}"
    ]
  }
}
