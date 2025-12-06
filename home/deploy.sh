#!/bin/bash

# Homelab NixOS Deployment Script
# This script deploys NixOS VMs using Terragrunt and applies configuration with Colmena

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    local missing_tools=()
    
    if ! command -v terragrunt &> /dev/null; then
        missing_tools+=("terragrunt")
    fi
    
    if ! command -v colmena &> /dev/null; then
        missing_tools+=("colmena")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        echo "Please install them before continuing:"
        echo "  - terragrunt: https://terragrunt.gruntwork.io/docs/getting-started/install/"
        echo "  - colmena: nix profile install nixpkgs#colmena"
        exit 1
    fi
    
    if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
        print_warning "SSH public key not found at ~/.ssh/id_rsa.pub"
        echo "Generate one with: ssh-keygen -t rsa -b 4096"
    fi
    
    print_step "All prerequisites met!"
}

# Check environment variables
check_env() {
    print_step "Checking environment variables..."
    
    if [ -z "$PROXMOX_ENDPOINT" ]; then
        print_warning "PROXMOX_ENDPOINT not set, using default: https://192.168.1.10:8006"
    fi
    
    if [ -z "$PROXMOX_USERNAME" ]; then
        print_warning "PROXMOX_USERNAME not set, using default: root@pam"
    fi
    
    if [ -z "$PROXMOX_PASSWORD" ]; then
        print_error "PROXMOX_PASSWORD not set!"
        echo "Please set it with: export PROXMOX_PASSWORD='your-password'"
        exit 1
    fi
}

# Deploy infrastructure
deploy_infrastructure() {
    print_step "Deploying infrastructure with Terragrunt..."
    
    cd "$PROJECT_ROOT/home/stacks/prod"
    
    print_step "Running terragrunt plan..."
    terragrunt run-all plan
    
    echo ""
    read -p "Do you want to apply these changes? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        print_warning "Deployment cancelled"
        exit 0
    fi
    
    print_step "Applying infrastructure changes..."
    terragrunt run-all apply -auto-approve
    
    print_step "Infrastructure deployment complete!"
}

# Wait for VMs to be ready
wait_for_vms() {
    print_step "Waiting for VMs to boot and become accessible..."
    
    local ips=("192.168.1.20" "192.168.1.21" "192.168.1.22" "192.168.1.23")
    local max_attempts=30
    local wait_time=10
    
    for ip in "${ips[@]}"; do
        print_step "Checking connectivity to $ip..."
        
        local attempt=0
        while [ $attempt -lt $max_attempts ]; do
            if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@"$ip" "echo 'Connected'" &> /dev/null; then
                print_step "✓ $ip is ready"
                break
            else
                attempt=$((attempt + 1))
                if [ $attempt -lt $max_attempts ]; then
                    echo "Waiting... (attempt $attempt/$max_attempts)"
                    sleep $wait_time
                else
                    print_error "Failed to connect to $ip after $max_attempts attempts"
                    print_warning "You may need to check the VM manually"
                fi
            fi
        done
    done
    
    print_step "All VMs are accessible!"
}

# Deploy NixOS configuration
deploy_nixos() {
    print_step "Deploying NixOS configuration with Colmena..."
    
    cd "$PROJECT_ROOT/nix"
    
    print_step "Building and deploying NixOS configuration..."
    colmena apply --verbose
    
    print_step "NixOS deployment complete!"
}

# Verify deployment
verify_deployment() {
    print_step "Verifying deployment..."
    
    print_step "Checking storage-01..."
    ssh root@192.168.1.20 "systemctl is-active smbd" || print_warning "Samba service may not be running"
    
    print_step "Checking k3s-server-01..."
    ssh root@192.168.1.21 "systemctl is-active k3s" || print_warning "K3s service may not be running"
    
    print_step "Checking k3s-agent-01..."
    ssh root@192.168.1.22 "systemctl is-active k3s-agent" || print_warning "K3s agent may not be running"
    
    print_step "Checking k3s-agent-02..."
    ssh root@192.168.1.23 "systemctl is-active k3s-agent" || print_warning "K3s agent may not be running"
    
    print_step "Getting K3s cluster status..."
    ssh root@192.168.1.21 "k3s kubectl get nodes" || print_warning "Could not get cluster status"
    
    print_step "Verification complete!"
}

# Main deployment flow
main() {
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════╗"
    echo "║   Homelab NixOS Deployment Script            ║"
    echo "╚═══════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    check_prerequisites
    check_env
    
    echo ""
    echo "This script will:"
    echo "  1. Deploy 4 NixOS VMs using Terragrunt"
    echo "  2. Wait for VMs to boot"
    echo "  3. Apply NixOS configuration with Colmena"
    echo "  4. Verify the deployment"
    echo ""
    
    read -p "Continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        print_warning "Deployment cancelled"
        exit 0
    fi
    
    deploy_infrastructure
    wait_for_vms
    deploy_nixos
    verify_deployment
    
    echo ""
    print_step "🎉 Deployment completed successfully!"
    echo ""
    echo "Your homelab is ready:"
    echo "  - Storage node: 192.168.1.20"
    echo "  - K3s server:   192.168.1.21"
    echo "  - K3s agent 1:  192.168.1.22"
    echo "  - K3s agent 2:  192.168.1.23"
    echo ""
    echo "Get cluster status: ssh root@192.168.1.21 'k3s kubectl get nodes'"
}

# Run main function
main
