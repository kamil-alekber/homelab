unit "k0s-containers" {
  source = "../../units/lxc"
  path   = "lxc"

  values = {
    version        = "HEAD"
    desired_count  = 5

    target_node    = "node-1"
    host_prefix    = "k0s"
    ipv4_ip_start  = 100
    ssh_public_keys = "~/.ssh/id_rsa"
  }
}

