{ config, pkgs, lib, ... }:

# WARNING: K3s token and Samba credentials are hardcoded.
# In production:
# 1. Use NixOps secrets or agenix for encrypted secrets
# 2. Token must match the server token
# 3. Generate strong passwords and tokens
#
# Current demo credentials (CHANGE THESE!):
# - K3s token: v1OTu/xJ2CGP1S1+ub92/tv4hDjOdAOslWHEZ67IIO0=
# - Samba password: 95782641

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

  # Create token file (must match server token)
  # Moved to systemd.tmpfiles.rules above with smbcredentials

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

  environment.systemPackages = with pkgs; [
    k3s
    cifs-utils  # For mounting Samba shares
    nfs-utils   # For NFS mounts
  ];

  # Create Samba credentials file for mounting shares
  systemd.tmpfiles.rules = [
    "d /var/lib/rancher/k3s/agent 0755 root root -"
    "f /var/lib/rancher/k3s/agent/token 0600 root root - v1OTu/xJ2CGP1S1+ub92/tv4hDjOdAOslWHEZ67IIO0="
    "f /root/.smbcredentials 0600 root root - username=samba\npassword=95782641"
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
