unit "storage-01" {
  source = "../../units/storage-01"
  path   = "storage-01"
}

unit "k3s-server-01" {
  source = "../../units/k3s-server-01"
  path   = "k3s-server-01"
}

unit "k3s-agents" {
  source = "../../units/k3s-agents"
  path   = "k3s-agents"
}
