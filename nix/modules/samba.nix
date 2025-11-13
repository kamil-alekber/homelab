{ config, pkgs, lib, ... }:

{
  # Networking configuration for Samba
  networking.firewall.allowedTCPPorts = [ 139 445 2049 111 ];
  networking.firewall.allowedUDPPorts = [ 137 138 2049 111 ];

  networking.interfaces.ens18 = {  # Replace with your interface name (use `ip a` to find it)
    useDHCP = false;
    ipv4.addresses = [{
      address = "192.168.8.221";
      prefixLength = 24;
    }];
  };

  # Additional storage-specific packages
  environment.systemPackages = with pkgs; [
    cifs-utils
    samba
    nfs-utils
  ];

  # Samba configuration
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    
    extraConfig = ''
      workgroup = HOMELAB
      server string = Homelab Storage Server
      netbios name = storage-01
      security = user
      
      # Performance tuning
      socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
      read raw = yes
      write raw = yes
      
      # Logging
      log file = /var/log/samba/%m.log
      max log size = 50
      
      # Name resolution
      dns proxy = no
    '';
    
    shares = {
      media = {
        path = "/storage/media";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "samba";
        "force group" = "samba";
        comment = "Media Storage Share";
      };
      
      backups = {
        path = "/storage/backups";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0600";
        "directory mask" = "0700";
        "force user" = "samba";
        "force group" = "samba";
        comment = "Backup Storage Share";
      };
      
      shared = {
        path = "/storage/shared";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "samba";
        "force group" = "samba";
        comment = "Shared Storage";
      };
    };
  };

  # Samba user and group
  users.users.samba = {
    isSystemUser = true;
    group = "samba";
    description = "Samba service user";
  };

  users.groups.samba = {};

  # NFS server (optional, for K8s integration)
  services.nfs.server = {
    enable = true;
    exports = ''
      /storage/k8s-volumes 192.168.8.0/24(rw,sync,no_subtree_check,no_root_squash)
    '';
  };

  # File system configuration - must be defined BEFORE tmpfiles
  fileSystems."/storage" = {
    device = "/dev/disk/by-uuid/98afcbf6-dfb5-4a8c-93e8-86fcd2e07c6c";
    fsType = "ext4";
    options = [ "defaults" "noatime" ];
  };

  # Create storage directories after filesystem is mounted
  systemd.services."setup-storage-dirs" = {
    description = "Setup storage directories";
    after = [ "local-fs.target" ];
    requires = [ "storage.mount" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Create directories
      mkdir -p /storage/media /storage/backups /storage/shared /storage/k8s-volumes
      
      # Set ownership
      chown samba:samba /storage/media /storage/backups /storage/shared
      chown root:root /storage/k8s-volumes
      
      # Set permissions
      chmod 0755 /storage/media /storage/shared
      chmod 0700 /storage/backups
      chmod 0755 /storage/k8s-volumes
    '';
  };

  # Enable periodic TRIM for SSDs (if applicable)
  # services.fstrim.enable = true;
}
