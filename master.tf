resource "azurerm_managed_disk" "master" {
  count                = "${var.num_of_masters}"
  name                 = "${var.master_name_prefix}${count.index + 1}-managed-disk"
  location             = "${var.region}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "${var.instance_disk_size}"
}

resource "azurerm_network_security_group" "master" {
  name                = "${var.master_name_prefix}-security-group"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_network_interface" "master" {
  count                     = "${var.num_of_masters}"
  name                      = "${var.master_name_prefix}${count.index + 1}-nic"
  location                  = "${var.region}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.master.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "${var.master_name_prefix}${count.index + 1}-ip-config"
    subnet_id                     = "${local.subnet_id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "master_nic_backend_pool" {
  count                   = "${var.num_of_masters}"
  network_interface_id    = "${azurerm_network_interface.master.*.id[count.index]}"
  ip_configuration_name   = "${var.master_name_prefix}${count.index + 1}-ip-config"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.master_backend_pool.id}"
}

resource "azurerm_availability_set" "master" {
  name                         = "${var.master_name_prefix}-as"
  location                     = "${var.region}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count  = 3
  platform_update_domain_count = 1
  managed                      = true
}

resource "azurerm_virtual_machine" "master" {
  count                            = "${var.num_of_masters}"
  name                             = "${var.master_name_prefix}${count.index + 1}"
  location                         = "${var.region}"
  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${azurerm_network_interface.master.*.id[count.index]}"]
  vm_size                          = "${var.master_instance_type}"
  availability_set_id              = "${azurerm_availability_set.master.id}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.master_name_prefix}${count.index + 1}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.master.*.name[count.index]}"
    managed_disk_id = "${azurerm_managed_disk.master.*.id[count.index]}"
    create_option   = "Attach"
    lun             = 0
    disk_size_gb    = "${azurerm_managed_disk.master.*.disk_size_gb[count.index]}"
  }

  os_profile {
    computer_name  = "${var.master_name_prefix}${count.index + 1}"
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
      type         = "ssh"
      user         = "${var.os_username}"
      host         = "${element(azurerm_network_interface.master.*.private_ip_address, count.index)}"
      bastion_host = "${azurerm_public_ip.bootstrap.fqdn}"
      private_key  = "${local.private_key}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/setup.sh",
      "sudo bash /tmp/setup.sh",
    ]

    connection {
      type         = "ssh"
      user         = "${var.os_username}"
      host         = "${element(azurerm_network_interface.master.*.private_ip_address, count.index)}"
      bastion_host = "${azurerm_public_ip.bootstrap.fqdn}"
      private_key  = "${local.private_key}"
    }
  }
}
