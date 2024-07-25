resource "azurerm_resource_group" "mtc-rg" {
  name     = "mtc-resources"
  location = "West Europe"
  tags = {
    environment = "test"
  }
}
