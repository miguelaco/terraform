resource "azurerm_public_ip" "master_lb_public_ip" {
  name                         = "master-lb-public-ip"
  location                     = "${var.region}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "master-lb-${var.cluster_id}"
}

resource "azurerm_lb" "master_lb" {
  name                = "master-lb"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                 = "master-lb-ip-config"
    public_ip_address_id = "${azurerm_public_ip.master_lb_public_ip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "master_backend_pool" {
  name                = "master-backend-pool"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.master_lb.id}"
}

resource "azurerm_lb_rule" "master_lb_https_rule" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.master_lb.id}"
  name                           = "https-rule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "master-lb-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.master_backend_pool.id}"
  load_distribution              = "SourceIP"
  probe_id                       = "${azurerm_lb_probe.master_lb_https_probe.id}"
  depends_on                     = ["azurerm_lb_probe.master_lb_https_probe"]
}

resource "azurerm_lb_rule" "master_lb_sso_rule" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.master_lb.id}"
  name                           = "sso-rule"
  protocol                       = "Tcp"
  frontend_port                  = 9005
  backend_port                   = 9005
  frontend_ip_configuration_name = "master-lb-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.master_backend_pool.id}"
  load_distribution              = "SourceIP"
  probe_id                       = "${azurerm_lb_probe.master_lb_sso_probe.id}"
  depends_on                     = ["azurerm_lb_probe.master_lb_sso_probe"]
}

resource "azurerm_lb_probe" "master_lb_https_probe" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.master_lb.id}"
  name                = "https-probe"
  port                = 443
}

resource "azurerm_lb_probe" "master_lb_sso_probe" {
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.master_lb.id}"
  name                = "sso-probe"
  port                = 9005
}
