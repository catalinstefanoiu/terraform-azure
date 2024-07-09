output "public_ip_address" {
  value = [for i in range(var.vm_count) : "${azurerm_linux_virtual_machine.mtc-vm[i].name}: ${data.azurerm_public_ip.mtc-ip-data[i].ip_address}"]
}

output "vm_password" {
  value     = random_password.vm_password.result
  sensitive = true
}
