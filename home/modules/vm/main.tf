locals {
  use_multi = var.desired_count > 1
}

resource "proxmox_vm_qemu" "vm" {
    count       = var.desired_count

    vmid        = local.use_multi ? 0 : var.vmid
    name        = local.use_multi ? format("%s-%d", coalesce(var.host_prefix, var.name), count.index) : var.name
    target_node = var.target_node
    onboot      = var.onboot
    clone       = var.template
    full_clone  = var.full_clone
    
    network {
        id     = 0
        model  = "virtio"
        bridge = "vmbr0"
    }

    # Optional static IPv4 via cloud-init (ipconfig0)
    ipconfig0 = var.ipv4_network != null ? (
      local.use_multi ?
        format(
          "ip=%s.%d/%d,gw=%s",
          var.ipv4_network,
          var.ipv4_ip_start + count.index,
          var.ipv4_cidr,
          coalesce(var.ipv4_gateway, format("%s.1", var.ipv4_network))
        ) : (
        var.ipv4_ip != null ?
          format(
            "ip=%s.%d/%d,gw=%s",
            var.ipv4_network,
            var.ipv4_ip,
            var.ipv4_cidr,
            coalesce(var.ipv4_gateway, format("%s.1", var.ipv4_network))
          ) : null
      )
    ) : null

    lifecycle {
        ignore_changes = [
            vmid,
            network
        ]
    }
}