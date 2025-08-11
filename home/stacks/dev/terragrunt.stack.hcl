unit "k0s-vm" {
  source = "../../units/vm"
  path   = "vm"

  values = {
    version       = "HEAD"
    desired_count = 2
  }
}
