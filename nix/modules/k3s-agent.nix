{ config, pkgs, lib, ... }:

{
  # K3s agent (worker) configuration
  services.k3s = {
    enable = true;
    role = "agent";
    
    # Server address is set in flake.nix per-node configuration
    # serverAddr is passed from the node config
    
    extraFlags = toString [
      "--node-label=node-role.kubernetes.io/worker=true"
    ];
    
    # Token for joining the cluster (must match server token)
    tokenFile = "/var/lib/rancher/k3s/agent/token";
  };

  # Create token file (YOU MUST CHANGE THIS to match server token!)
  systemd.tmpfiles.rules = [
    "d /var/lib/rancher/k3s/agent 0755 root root -"
    "f /var/lib/rancher/k3s/agent/token 0600 root root - changeme-replace-with-secure-token"
  ];

  # Networking for K3s agent
  networking.firewall.allowedTCPPorts = [
    10250 # Kubelet metrics
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

  # Additional packages
  environment.systemPackages = with pkgs; [
    k3s
    cifs-utils  # For mounting Samba shares
    nfs-utils   # For NFS mounts
  ];

  # Optional: Mount Samba share for persistent storage
  # fileSystems."/mnt/storage" = {
  #   device = "//storage-01/media";
  #   fsType = "cifs";
  #   options = [ "credentials=/root/.smbcredentials" "uid=1000" "gid=1000" "x-systemd.automount" ];
  # };

  # Ensure K3s starts after network is up
  systemd.services.k3s.after = [ "network-online.target" ];
  systemd.services.k3s.wants = [ "network-online.target" ];
}
