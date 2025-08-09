resource "proxmox_vm_qemu" "vm" {
    vmid        = var.vmid
    name        = var.name
    target_node = var.target_node
    onboot      = var.onboot
    memory      = var.memory
    clone       = var.template

    cpu {
        cores = var.cores
    }

    network {
        id = 0
        model = "virtio"
        bridge = "vmbr0"
    }

    lifecycle {
        ignore_changes = [
            vmid,
            network
    ]
  }
}