{ config, pkgs, lib, ... }:

# WARNING: K3s token is hardcoded in this configuration.
# In production:
# 1. Generate a strong random token: openssl rand -base64 32
# 2. Use NixOps secrets or agenix to manage the token securely
# 3. Never commit the actual token to version control
#
# Current demo token: v1OTu/xJ2CGP1S1+ub92/tv4hDjOdAOslWHEZ67IIO0= (CHANGE THIS!)

{
  # K3s server (control plane) configuration
  services.k3s = {
    enable = true;
    role = "server";
    
    extraFlags = toString [
      "--disable=traefik" # We'll use our own ingress
      "--disable=servicelb" # Using MetalLB instead
      "--write-kubeconfig-mode=644"
      "--tls-san=${config.networking.hostName}"
      "--tls-san=192.168.1.248"  # k3s-server-01 IP
      "--tls-san=k3s-server-01.local"
      "--node-label=node-role.kubernetes.io/control-plane=true"
    ];
    
    # Token for agents to join (YOU MUST CHANGE THIS!)
    tokenFile = "/var/lib/rancher/k3s/server/token";
  };

  # Create token file if it doesn't exist
  systemd.tmpfiles.rules = [
    "f /var/lib/rancher/k3s/server/token 0600 root root - v1OTu/xJ2CGP1S1+ub92/tv4hDjOdAOslWHEZ67IIO0="
  ];

  # Networking for K3s
  networking.firewall.allowedTCPPorts = [
    6443  # Kubernetes API
    10250 # Kubelet
    2379  # etcd client
    2380  # etcd peer
  ];

  networking.firewall.allowedUDPPorts = [
    8472  # Flannel VXLAN
  ];

  # Enable IP forwarding
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
  };

  # Load required kernel modules
  boot.kernelModules = [ "br_netfilter" "overlay" ];

  # Additional packages for Kubernetes management
  environment.systemPackages = with pkgs; [
    k3s
    kubectl
    kubernetes-helm
  ];

  # Storage for K3s
  # K3s will use local-path provisioner by default
  # You can mount additional storage here
  # fileSystems."/var/lib/rancher/k3s/storage" = {
  #   device = "/dev/disk/by-uuid/YOUR-UUID-HERE";
  #   fsType = "ext4";
  # };

  # Environment variables for kubectl
  environment.variables = {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
  };

  # Copy kubeconfig for external access
  # The kubeconfig will be accessible at /etc/rancher/k3s/k3s.yaml
  # To use it externally:
  # 1. Copy from server: scp root@192.168.1.248:/etc/rancher/k3s/k3s.yaml ~/.kube/homelab-config
  # 2. Update server IP: sed -i 's/127.0.0.1/192.168.1.248/g' ~/.kube/homelab-config
  # 3. Use: export KUBECONFIG=~/.kube/homelab-config
  
  systemd.services."k3s-export-kubeconfig" = {
    description = "Export K3s kubeconfig for external access";
    after = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Wait for kubeconfig to be created
      timeout=30
      while [ ! -f /etc/rancher/k3s/k3s.yaml ] && [ $timeout -gt 0 ]; do
        sleep 1
        timeout=$((timeout - 1))
      done
      
      if [ -f /etc/rancher/k3s/k3s.yaml ]; then
        # Create a copy with external IP
        cp /etc/rancher/k3s/k3s.yaml /etc/rancher/k3s/k3s-external.yaml
        ${pkgs.gnused}/bin/sed -i 's/127.0.0.1:6443/192.168.1.248:6443/g' /etc/rancher/k3s/k3s-external.yaml
        chmod 644 /etc/rancher/k3s/k3s-external.yaml
        echo "Kubeconfig exported to /etc/rancher/k3s/k3s-external.yaml"
      fi
    '';
  };

  # Ensure K3s starts after network is up
  systemd.services.k3s.after = [ "network-online.target" ];
  systemd.services.k3s.wants = [ "network-online.target" ];
}
