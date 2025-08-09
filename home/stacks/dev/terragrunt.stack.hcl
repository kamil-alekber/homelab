unit "lxc-containers" {
  source = "../../units/lxc"
  path   = "lxc"

  values = {
    desired_count  = 2
    version        = "HEAD"
  }
}

