locals {
  private_key = "${file("./secrets/${var.cluster_id}")}"
  public_key = "${file("./secrets/${var.cluster_id}.pub")}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.cluster_id}"
  location = "${var.region}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.32.0.0/16"]
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  address_prefix       = "10.32.0.0/22"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_route_table" "route_table" {
  name                = "route-table"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet_route_table_association" "subnet_route_table" {
  subnet_id      = "${azurerm_subnet.subnet.id}"
  route_table_id = "${azurerm_route_table.route_table.id}"
}