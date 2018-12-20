resource "azurerm_managed_disk" "gosec" {
  count                = "${var.num_of_gosecs}"
  name                 = "${var.gosec_name_prefix}${count.index + 1}-managed-disk"
  location             = "${var.region}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "${var.instance_disk_size}"
}

resource "azurerm_network_interface" "gosec" {
  count                = "${var.num_of_gosecs}"
  name                 = "${var.gosec_name_prefix}${count.index + 1}-nic"
  location             = "${var.region}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "${var.gosec_name_prefix}${count.index + 1}-ip-config"
    subnet_id                     = "${local.subnet_id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_availability_set" "gosec" {
  name                         = "${var.gosec_name_prefix}-as"
  location                     = "${var.region}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_fault_domain_count  = 3
  platform_update_domain_count = 1
  managed                      = true
}

resource "azurerm_virtual_machine" "gosec" {
  count                            = "${var.num_of_gosecs}"
  name                             = "${var.gosec_name_prefix}${count.index + 1}"
  location                         = "${var.region}"
  resource_group_name              = "${azurerm_resource_group.rg.name}"
  network_interface_ids            = ["${azurerm_network_interface.gosec.*.id[count.index]}"]
  vm_size                          = "${var.gosec_instance_type}"
  availability_set_id              = "${azurerm_availability_set.gosec.id}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.gosec_name_prefix}${count.index + 1}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.gosec.*.name[count.index]}"
    managed_disk_id = "${azurerm_managed_disk.gosec.*.id[count.index]}"
    create_option   = "Attach"
    lun             = 0
    disk_size_gb    = "${azurerm_managed_disk.gosec.*.disk_size_gb[count.index]}"
  }

  os_profile {
    computer_name  = "${var.gosec_name_prefix}${count.index + 1}"
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
      host         = "${element(azurerm_network_interface.gosec.*.private_ip_address, count.index)}"
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
      host         = "${element(azurerm_network_interface.gosec.*.private_ip_address, count.index)}"
      bastion_host = "${azurerm_public_ip.bootstrap.fqdn}"
      private_key  = "${local.private_key}"
    }
  }
}
