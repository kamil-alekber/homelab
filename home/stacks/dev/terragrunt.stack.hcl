unit "k0s-containers" {
  source = "../../units/lxc"
  path   = "lxc"

  values = {
    version        = "HEAD"
    desired_count  = 5
  }
}

unit "k0s-vm" {
  source = "../../units/vm"
  path   = "vm"

  values = {
    version       = "HEAD"
  }
}

