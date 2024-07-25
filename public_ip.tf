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
