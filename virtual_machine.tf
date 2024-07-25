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

   custom_data = filebase64("customdata.tpl")

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

# data "azurerm_public_ip" "mtc-ip-data" {
 # count               = var.vm_count
  # name                = azurerm_public_ip.mtc-ip[count.index].name
  # resource_group_name = azurerm_resource_group.mtc-rg.name
# }