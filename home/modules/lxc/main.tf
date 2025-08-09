resource "proxmox_lxc" "basic-[count.index]" {
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
    ip     = var.ipv4_address
    gw     = var.ipv4_gateway
    ip6    = var.ipv6_address
    gw6    = var.ipv6_gateway
  }
}
