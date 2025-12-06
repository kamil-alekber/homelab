# NixOS Homelab Deployment Guide

This directory contains Terragrunt configurations for deploying NixOS VMs on Proxmox infrastructure.

## Prerequisites

1. **Proxmox VE** server running and accessible
2. **Terragrunt** installed (`brew install terragrunt` or download from GitHub)
3. **Terraform** installed (will be automatically downloaded by Terragrunt if not present)
4. **Colmena** installed for NixOS deployment (`nix profile install nixpkgs#colmena`)
5. SSH key pair generated (`~/.ssh/id_rsa.pub`)

## Environment Variables

Set these environment variables before deployment:

```bash
export PROXMOX_ENDPOINT="https://your-proxmox-ip:8006"
export PROXMOX_USERNAME="root@pam"
export PROXMOX_PASSWORD="your-password"
```

Or create a `.envrc` file:

```bash
export PROXMOX_ENDPOINT="https://192.168.1.10:8006"
export PROXMOX_USERNAME="root@pam"
export PROXMOX_PASSWORD="your-secure-password"
```

## Infrastructure Overview

This deployment creates 4 NixOS VMs:

1. **storage-01** (192.168.1.20) - Samba storage node
   - 2 CPU cores
   - 4GB RAM
   - 100GB disk

2. **k3s-server-01** (192.168.1.21) - K3s control plane
   - 4 CPU cores
   - 8GB RAM
   - 50GB disk

3. **k3s-agent-01** (192.168.1.22) - K3s worker node 1
   - 4 CPU cores
   - 8GB RAM
   - 50GB disk

4. **k3s-agent-02** (192.168.1.23) - K3s worker node 2
   - 4 CPU cores
   - 8GB RAM
   - 50GB disk

## Deployment Steps

### Step 1: Deploy Infrastructure with Terragrunt

Navigate to the stack directory and deploy:

```bash
cd home/stacks/prod

# Initialize and plan
terragrunt run-all plan

# Apply infrastructure
terragrunt run-all apply
```

Or deploy individual units:

```bash
cd home/units/storage-01
terragrunt apply

cd ../k3s-server-01
terragrunt apply

cd ../k3s-agents
terragrunt apply
```

### Step 2: Wait for VMs to Boot

After Terragrunt creates the VMs, wait 2-3 minutes for them to fully boot and become accessible via SSH.

Test SSH connectivity:

```bash
ssh root@192.168.1.20
ssh root@192.168.1.21
ssh root@192.168.1.22
ssh root@192.168.1.23
```

### Step 3: Deploy NixOS Configuration with Colmena

Navigate to the nix directory and deploy the flake configuration:

```bash
cd ../../nix

# Build and deploy to all nodes
colmena apply

# Or deploy to specific nodes/tags
colmena apply --on storage-01
colmena apply --on @k3s
colmena apply --on @k3s-server
colmena apply --on @k3s-agent
```

### Step 4: Verify Deployment

Check that all services are running:

```bash
# Check storage node
ssh root@192.168.1.20 "systemctl status smbd"

# Check k3s server
ssh root@192.168.1.21 "systemctl status k3s"

# Check k3s agents
ssh root@192.168.1.22 "systemctl status k3s-agent"
ssh root@192.168.1.23 "systemctl status k3s-agent"

# Get k3s cluster status
ssh root@192.168.1.21 "k3s kubectl get nodes"
```

## Updating Configuration

### Update Infrastructure

Modify the terragrunt.hcl files in `home/units/` and run:

```bash
cd home/stacks/prod
terragrunt run-all apply
```

### Update NixOS Configuration

Modify the nix modules in `nix/modules/` or `nix/flake.nix` and run:

```bash
cd nix
colmena apply
```

## Destroying Infrastructure

To destroy all resources:

```bash
cd home/stacks/prod
terragrunt run-all destroy
```

## Troubleshooting

### VMs don't start
- Check Proxmox console for boot errors
- Verify the NixOS cloud image downloaded successfully
- Check that the target Proxmox node has sufficient resources

### SSH connection refused
- Wait longer for VMs to boot (can take 3-5 minutes)
- Check VM console in Proxmox
- Verify IP addresses are correct and not conflicting

### Colmena deployment fails
- Verify SSH connectivity to all nodes
- Check that your SSH key is properly configured
- Run `colmena apply --verbose` for detailed output

## Directory Structure

```
home/
├── root.hcl                     # Common Terragrunt configuration
├── modules/
│   └── nixos-vm/                # NixOS VM Terraform module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
├── units/
│   ├── storage-01/              # Storage node configuration
│   ├── k3s-server-01/           # K3s server configuration
│   └── k3s-agents/              # K3s agents configuration
└── stacks/
    └── prod/                    # Production stack
        └── terragrunt.stack.hcl
```
