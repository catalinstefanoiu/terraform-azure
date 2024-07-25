# data "azurerm_public_ip" "mtc-ip-data" {
 # count               = var.vm_count
  # name                = azurerm_public_ip.mtc-ip[count.index].name
  # resource_group_name = azurerm_resource_group.mtc-rg.name
# }

resource "null_resource" "test-ping" {
  for_each = {
    for idx, ip in azurerm_public_ip.mtc-ip : idx => {
      public_ip  = ip.ip_address
      private_ip = azurerm_network_interface.mtc-nic[idx].private_ip_address
    }
  }

  depends_on = [azurerm_public_ip.mtc-ip, azurerm_network_interface.mtc-nic]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = each.value.public_ip
      user        = "adminuser"
      private_key = file("~/.ssh/mtcazureke")
    }

    inline = [
      "sleep 30",
      "ping -c 4 ${each.value.private_ip}"
    ]
  }
}