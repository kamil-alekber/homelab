# Homelab NixOS Deployment with Colmena

This directory contains the NixOS configuration for the homelab infrastructure, managed and deployed using Colmena.

## Architecture

The homelab consists of 4 nodes:

1. **storage-01** - Samba/NFS storage server
2. **k3s-server-01** - K3s control plane node
3. **k3s-agent-01** - K3s worker node 1
4. **k3s-agent-02** - K3s worker node 2

## Prerequisites

1. **Install Colmena**:
   ```bash
   nix profile install nixpkgs#colmena
   # or with flakes:
   nix shell nixpkgs#colmena
   ```

2. **NixOS installed on all target machines** with SSH access

3. **SSH keys configured** for passwordless root access to all nodes

## Configuration Steps

### 1. Update IP Addresses

Edit `flake.nix` and update the `targetHost` values for each node:

```nix
storage-01.deployment.targetHost = "192.168.8.221";  # Your actual IP
k3s-server-01.deployment.targetHost = "192.168.1.21";
k3s-agent-01.deployment.targetHost = "192.168.1.22";
k3s-agent-02.deployment.targetHost = "192.168.1.23";
```

### 2. Configure SSH Keys

Edit `modules/common.nix` and add your SSH public keys:

```nix
users.users.root.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAAC3NzaC1... your-key-here"
];
```

### 3. Set K3s Cluster Token

**IMPORTANT**: Change the K3s token in both:
- `modules/k3s-server.nix` 
- `modules/k3s-agent.nix`

Generate a secure token:
```bash
openssl rand -hex 32
```

Update the token in both files:
```nix
"f /var/lib/rancher/k3s/server/token 0600 root root - YOUR-SECURE-TOKEN-HERE"
```

### 4. Configure Storage (Optional)

Edit `modules/samba.nix` to configure your storage device:

```nix
fileSystems."/storage" = {
  device = "/dev/disk/by-uuid/YOUR-UUID-HERE";
  fsType = "ext4";
  options = [ "defaults" "noatime" ];
};
```

## Deployment Commands

### Initial Setup

1. **Build the configuration** (test without deploying):
   ```bash
   cd nix
   colmena build
   ```

2. **Deploy to all nodes**:
   ```bash
   colmena apply
   ```

3. **Deploy to specific nodes**:
   ```bash
   colmena apply --on storage-01
   colmena apply --on k3s-server-01,k3s-agent-01
   ```

4. **Deploy by tags**:
   ```bash
   colmena apply --on @storage    # Deploy storage nodes
   colmena apply --on @k3s        # Deploy all k3s nodes
   colmena apply --on @k3s-server # Deploy only k3s server
   colmena apply --on @k3s-agent  # Deploy only k3s agents
   ```

### Common Operations

**Check configuration**:
```bash
colmena eval --instantiate
```

**Upload keys** (if using deployment.keys):
```bash
colmena upload-keys
```

**Execute commands on nodes**:
```bash
colmena exec --on k3s-server-01 -- kubectl get nodes
colmena exec --on @k3s -- systemctl status k3s
```

**Reboot nodes**:
```bash
colmena apply --on k3s-agent-01 --reboot
```

**Build locally** (faster for development):
```bash
colmena build --on storage-01
```

**Show node info**:
```bash
colmena introspect
```

## Post-Deployment

### K3s Cluster

1. **Get kubeconfig from the server**:
   ```bash
   ssh root@k3s-server-01 cat /etc/rancher/k3s/k3s.yaml > kubeconfig.yml
   # Update the server address in kubeconfig.yml
   sed -i 's/127.0.0.1/192.168.1.21/g' kubeconfig.yml
   ```

2. **Check cluster status**:
   ```bash
   export KUBECONFIG=./kubeconfig.yml
   kubectl get nodes
   ```

### Samba Storage

1. **Set Samba passwords**:
   ```bash
   ssh root@storage-01
   smbpasswd -a samba
   ```

2. **Test Samba share**:
   ```bash
   smbclient //storage-01/media -U samba
   ```

3. **Mount from K8s** - The storage node exports NFS at `/storage/k8s-volumes`

## Troubleshooting

**SSH issues**:
```bash
# Test SSH connectivity
colmena apply --on storage-01 --dry-run
```

**View logs**:
```bash
colmena exec --on k3s-server-01 -- journalctl -u k3s -f
```

**Rebuild and switch**:
```bash
colmena apply --on k3s-server-01 --build-on-target
```

**Roll back** (if you have previous generations):
```bash
ssh root@k3s-server-01
nixos-rebuild --rollback switch
```

## Security Notes

⚠️ **IMPORTANT**: 
- Change the default K3s token!
- Configure proper SSH keys in `common.nix`
- Update firewall rules as needed
- Set strong Samba passwords
- Consider using Colmena's deployment keys for secrets

## Directory Structure

```
nix/
├── flake.nix              # Main Colmena configuration
├── flake.lock             # Lock file for inputs
└── modules/
    ├── common.nix         # Shared configuration
    ├── samba.nix          # Samba storage config
    ├── k3s-server.nix     # K3s control plane
    └── k3s-agent.nix      # K3s worker nodes
```

## Next Steps

1. Deploy your existing ArgoCD applications to the new K3s cluster
2. Configure MetalLB for LoadBalancer services
3. Set up cert-manager for TLS certificates
4. Configure external-dns for automatic DNS updates
5. Mount NFS/Samba storage in K8s pods

## Resources

- [Colmena Documentation](https://colmena.cli.rs/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [K3s Documentation](https://docs.k3s.io/)
