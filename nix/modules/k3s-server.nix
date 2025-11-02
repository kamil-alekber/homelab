{ config, pkgs, lib, ... }:

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
      "--node-label=node-role.kubernetes.io/control-plane=true"
    ];
    
    # Token for agents to join (YOU MUST CHANGE THIS!)
    tokenFile = "/var/lib/rancher/k3s/server/token";
  };

  # Create token file if it doesn't exist
  systemd.tmpfiles.rules = [
    "f /var/lib/rancher/k3s/server/token 0600 root root - changeme-replace-with-secure-token"
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

  # Ensure K3s starts after network is up
  systemd.services.k3s.after = [ "network-online.target" ];
  systemd.services.k3s.wants = [ "network-online.target" ];
}
