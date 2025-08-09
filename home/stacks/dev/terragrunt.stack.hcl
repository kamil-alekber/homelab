unit "k0s-containers" {
  source = "../../units/lxc"
  path   = "lxc"

  values = {
    version        = "HEAD"
    desired_count  = 5
  }
}

