unit "k0s-containers" {
  source = "../../units/lxc"
  path   = "lxc"

  values = {
    desired_count  = 2
    version        = "HEAD"
    target_node    = "node-1"
    host_prefix    = "k0s"
  }
}

