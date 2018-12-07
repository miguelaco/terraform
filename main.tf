resource "azurerm_resource_group" "eos" {
  name     = "${var.cluster_id}"
  location = "${var.azure_region}"
}

resource "azurerm_virtual_network" "eos" {
  name                = "vnet-${var.cluster_id}"
  address_space       = ["10.32.0.0/16"]
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.eos.name}"
}

resource "azurerm_subnet" "eos" {
  name                 = "subnet-${var.cluster_id}"
  address_prefix       = "10.32.0.0/22"
  virtual_network_name = "${azurerm_virtual_network.eos.name}"
  resource_group_name  = "${azurerm_resource_group.eos.name}"
}

resource "azurerm_route_table" "eos" {
  name                = "route-table-${var.cluster_id}"
  location            = "${var.azure_region}"
  resource_group_name = "${azurerm_resource_group.eos.name}"
}

resource "azurerm_subnet_route_table_association" "eos" {
  subnet_id      = "${azurerm_subnet.eos.id}"
  route_table_id = "${azurerm_route_table.eos.id}"
}