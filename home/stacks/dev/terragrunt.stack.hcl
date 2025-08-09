unit "k0s-containers" {
  source = "../../units/lxc"
  path   = "lxc"

  values = {
    version        = "HEAD"
    desired_count  = 2
    
    target_node    = "node-1"
    host_prefix    = "k0s"
    ipv4_ip_start  = 100
  }
}

