resource "azurerm_managed_disk" "private_agent" {
  count                = "${var.num_of_private_agents}"
  name                 = "private-agent-managed-disk-${var.cluster_id}-${count.index + 1}"
  location             = "${var.azure_region}"
  resource_group_name  = "${azurerm_resource_group.eos.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "${var.instance_disk_size}"
}

resource "azurerm_network_interface" "private_agent" {
  count                = "${var.num_of_private_agents}"
  name                 = "private-agent-nic-${var.cluster_id}-${count.index + 1}"
  location             = "${var.azure_region}"
  resource_group_name  = "${azurerm_resource_group.eos.name}"
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "private-agent-ip-config-${var.cluster_id}-${count.index + 1}"
    subnet_id                     = "${azurerm_subnet.eos.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "private_agent" {
  count                            = "${var.num_of_private_agents}"
  name                             = "private-agent-${var.cluster_id}-${count.index + 1}"
  location                         = "${var.azure_region}"
  resource_group_name              = "${azurerm_resource_group.eos.name}"
  network_interface_ids            = ["${azurerm_network_interface.private_agent.*.id[count.index]}"]
  vm_size                          = "${var.azure_private_agent_instance_type}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  storage_os_disk {
    name              = "private-agent-os-disk-${var.cluster_id}-${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.private_agent.*.name[count.index]}"
    managed_disk_id = "${azurerm_managed_disk.private_agent.*.id[count.index]}"
    create_option   = "Attach"
    lun             = 0
    disk_size_gb    = "${azurerm_managed_disk.private_agent.*.disk_size_gb[count.index]}"
  }

  os_profile {
    computer_name  = "private-agent-${count.index + 1}"
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
      host         = "${element(azurerm_network_interface.private_agent.*.private_ip_address, count.index)}"
      bastion_host = "${azurerm_public_ip.bootstrap.fqdn}"
      private_key = "${local.private_key}"
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
      host         = "${element(azurerm_network_interface.private_agent.*.private_ip_address, count.index)}"
      bastion_host = "${azurerm_public_ip.bootstrap.fqdn}"
      private_key = "${local.private_key}"
    }
  }
}
