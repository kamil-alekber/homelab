data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key)
}

resource "proxmox_virtual_environment_vm" "nixos_vm" {
  count = var.desired_count

  name            = format("%s-%d", var.host_prefix, count.index + 1)
  node_name       = var.target_node
  stop_on_destroy = true

  cpu {
    cores = var.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory
    floating  = var.memory
  }

  initialization {
    ip_config {
      ipv4 {
        address = format(
          "%s/%s",
          element(var.ip_addresses, count.index),
          split("/", var.network_address)[1]
        )
        gateway = cidrhost(var.network_address, 1)
      }
    }

    user_account {
      username = var.ssh_username
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }

  disk {
    datastore_id = var.datastore_id
    import_from  = proxmox_virtual_environment_download_file.nixos_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.disk_size
  }

  network_device {
    bridge = "vmbr0"
  }

  # Enable QEMU guest agent
  agent {
    enabled = true
  }
}

resource "proxmox_virtual_environment_download_file" "nixos_cloud_image" {
  content_type = "import"
  datastore_id = "templates"
  node_name    = var.target_node
  url          = var.nixos_image_url
  file_name    = "nixos-${var.nixos_version}.qcow2"
}
