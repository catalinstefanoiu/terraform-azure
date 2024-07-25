resource "azurerm_container_registry" "acr" {
  name                = "devacr20240724"
  resource_group_name = azurerm_resource_group.mtc-rg.name
  location            = azurerm_resource_group.mtc-rg.location
  sku                 = "Basic"
  admin_enabled       = true
}