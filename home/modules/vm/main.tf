data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key)
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
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
    floating  = var.memory # set equal to dedicated to enable ballooning
  }


  initialization {
    ip_config {
      ipv4 {
        address = format(
          "%s/%s",
          cidrhost(var.network_address, var.ip_start_range + count.index),
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
    datastore_id = "local-lvm"
    import_from  = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "import"
  datastore_id = "templates"
  node_name    = "node-1"
  url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  # need to rename the file to *.qcow2 to indicate the actual file format for import
  file_name = "jammy-server-cloudimg-amd64.qcow2"
}
