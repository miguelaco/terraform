locals {
  private_key = "${file("./secrets/key")}"
  public_key  = "${file("./secrets/key.pub")}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.cluster_id}"
  location = "${var.region}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  count               = "${var.subnet_id != "" ? 0 : 1}"
  address_space       = ["${var.vnet_address_range}"]
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet" {
  count                = "${var.subnet_id != "" ? 0 : 1}"
  name                 = "subnet"
  address_prefix       = "${var.subnet_address_range}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  route_table_id       = "${azurerm_route_table.route_table.id}"
}

locals {
  subnet_id = "${var.subnet_id != "" ? var.subnet_id : element(concat(azurerm_subnet.subnet.*.id, list("")), 0)}"
}

resource "azurerm_route_table" "route_table" {
  name                = "route-table"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet_route_table_association" "subnet_route_table" {
  subnet_id      = "${local.subnet_id}"
  route_table_id = "${azurerm_route_table.route_table.id}"
}
