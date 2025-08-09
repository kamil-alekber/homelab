resource "proxmox_lxc" "basic" {
  count = var.desired_count

  target_node  = var.target_node
  hostname     = var.hostname
  ostemplate   = var.ostemplate
  password     = var.password
  unprivileged = var.unprivileged
  cores        = var.cores
  memory       = var.memory
  swap         = var.swap
  start        = var.start

  rootfs {
    storage = var.rootfs_storage
    size    = var.rootfs_size
  }

  network {
    name   = var.vnic_name
    bridge = var.vnic_bridge
    tag    = var.vlan_tag

    ip     = "${var.ipv4_network}.${count.index+1}/24"
    gw     = "${var.ipv4_network}.1"
    
    # ip6    = "${var.ipv6_network}:${count.index+1}/64"
    # gw6    = "${var.ipv6_network}.1"
  }

}
