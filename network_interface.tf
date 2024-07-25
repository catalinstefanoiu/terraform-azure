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
