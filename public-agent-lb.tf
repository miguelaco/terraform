resource "azurerm_public_ip" "public_agent_lb_public_ip" {
  count                        = "${var.num_of_public_agents > 0 ? 1 : 0}"
  name                         = "public-agent-lb-public-ip"
  location                     = "${var.region}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "public-agent-lb-${var.cluster_id}"
}

resource "azurerm_lb" "public_agent_lb" {
  count               = "${var.num_of_public_agents > 0 ? 1 : 0}"
  name                = "public-agent-lb"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                 = "public-agent-lb-ip-config"
    public_ip_address_id = "${azurerm_public_ip.public_agent_lb_public_ip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "public_agent_backend_pool" {
  count               = "${var.num_of_public_agents > 0 ? 1 : 0}"
  name                = "public-agent-backend-pool"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.public_agent_lb.id}"
}

resource "azurerm_lb_rule" "public_agent_lb_http_rule" {
  count                          = "${var.num_of_public_agents > 0 ? 1 : 0}"
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.public_agent_lb.id}"
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-agent-lb-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.public_agent_backend_pool.id}"
  load_distribution              = "SourceIP"
  probe_id                       = "${azurerm_lb_probe.public_agent_lb_http_probe.id}"
  depends_on                     = ["azurerm_lb_probe.public_agent_lb_http_probe"]
}

resource "azurerm_lb_rule" "public_agent_lb_https_rule" {
  count                          = "${var.num_of_public_agents > 0 ? 1 : 0}"
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${azurerm_lb.public_agent_lb.id}"
  name                           = "https-rule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "public-agent-lb-ip-config"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.public_agent_backend_pool.id}"
  load_distribution              = "SourceIP"
  probe_id                       = "${azurerm_lb_probe.public_agent_lb_https_probe.id}"
  depends_on                     = ["azurerm_lb_probe.public_agent_lb_https_probe"]
}

resource "azurerm_lb_probe" "public_agent_lb_http_probe" {
  count               = "${var.num_of_public_agents > 0 ? 1 : 0}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.public_agent_lb.id}"
  name                = "http-probe"
  port                = 80
}

resource "azurerm_lb_probe" "public_agent_lb_https_probe" {
  count               = "${var.num_of_public_agents > 0 ? 1 : 0}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.public_agent_lb.id}"
  name                = "https-probe"
  port                = 443
}
