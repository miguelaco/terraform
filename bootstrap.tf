resource "azurerm_managed_disk" "bootstrap" {
  name                 = "${var.bootstrap_name_prefix}-managed-disk"
  location             = "${var.region}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "${var.instance_disk_size}"
}

resource "azurerm_public_ip" "bootstrap" {
  name                         = "${var.bootstrap_name_prefix}-public-ip"
  location                     = "${var.region}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "bootstrap-${var.cluster_id}"
}

resource "azurerm_network_security_group" "bootstrap" {
  name                = "security-group-bootstrap"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_rule" "allow-ssh-inbound" {
  name                        = "allow-ssh-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.rg.name}"
  network_security_group_name = "${azurerm_network_security_group.bootstrap.name}"
}

resource "azurerm_network_interface" "bootstrap" {
  name                      = "${var.bootstrap_name_prefix}-nic"
  location                  = "${var.region}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.bootstrap.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "${var.bootstrap_name_prefix}-ip-config"
    subnet_id                     = "${local.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.bootstrap.id}"
  }
}

resource "azurerm_virtual_machine" "bootstrap" {
  name                             = "${var.bootstrap_name_prefix}"
  location                         = "${var.region}"
  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${azurerm_network_interface.bootstrap.id}"]
  vm_size                          = "${var.bootstrap_instance_type}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.bootstrap_name_prefix}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.bootstrap.name}"
    managed_disk_id = "${azurerm_managed_disk.bootstrap.id}"
    create_option   = "Attach"
    lun             = 0
    disk_size_gb    = "${azurerm_managed_disk.bootstrap.disk_size_gb}"
  }

  os_profile {
    computer_name  = "${var.bootstrap_name_prefix}"
    admin_username = "${var.os_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.os_username}/.ssh/authorized_keys"
      key_data = "${local.public_key}"
    }
  }

  provisioner "file" {
    source      = "scripts/setup.sh"
    destination = "/tmp/setup.sh"

    connection {
      type        = "ssh"
      user        = "${var.os_username}"
      host        = "${element(azurerm_public_ip.bootstrap.*.fqdn, count.index)}"
      private_key = "${local.private_key}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup.sh",
      "sudo bash /tmp/setup.sh",
    ]

    connection {
      type        = "ssh"
      user        = "${var.os_username}"
      host        = "${element(azurerm_public_ip.bootstrap.*.fqdn, count.index)}"
      private_key = "${local.private_key}"
    }
  }
}
