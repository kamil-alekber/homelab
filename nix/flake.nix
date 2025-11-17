{
  description = "Homelab NixOS Infrastructure with Colmena";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }:
    let
      system = "x86_64-linux";
    in
    {
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          
          # Specialized packages for nodes
          specialArgs = {
            unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
        };

        # Default settings for all nodes
        defaults = { pkgs, ... }: {
          imports = [
            ./modules/common.nix
          ];
        };

        # Samba storage node
        storage-01 = { name, nodes, pkgs, ... }: {
          deployment = {
            targetHost = "192.168.8.221"; # Change to your IP
            targetUser = "root";
            targetPort = 22;
            tags = [ "storage" ];
          };

          imports = [
            ./modules/samba.nix
          ];

 
 
        fileSystems."/" = {
          device = "/dev/disk/by-uuid/2f14a941-4301-4a71-a9b2-591625c386b7";
          fsType = "ext4";
        };

          networking.hostName = "storage-01";
          
          # System configuration
          system.stateVersion = "24.05";
        };

        # K3s control plane node
        k3s-server-01 = { name, nodes, pkgs, ... }: {
          deployment = {
            targetHost = "192.168.8.248"; # Change to your IP
            targetUser = "root";
            targetPort = 22;
            tags = [ "k3s" "k3s-server" ];
          };

          imports = [
            ./modules/k3s-server.nix
          ];

 
        fileSystems."/" = {
          device = "/dev/disk/by-uuid/bdd7d614-861b-4d90-b724-6be838ec786b";
          fsType = "ext4";
        };
          networking.hostName = "k3s-server-01";
          
          system.stateVersion = "24.05";
        };

        # K3s worker node 1
        k3s-agent-01 = { name, nodes, pkgs, ... }: {
          deployment = {
            targetHost = "192.168.8.223"; 
            targetUser = "root";
            targetPort = 22;
            tags = [ "k3s" "k3s-agent" ];
          };

          imports = [
            ./modules/k3s-agent.nix
          ];

 
        fileSystems."/" = {
          device = "/dev/disk/by-uuid/bdd7d614-861b-4d90-b724-6be838ec786b";
          fsType = "ext4";
        };
          networking.hostName = "k3s-agent-01";
          
          services.k3s.serverAddr = "https://192.168.8.248:6443";
          
          system.stateVersion = "24.05";
        };

        # K3s worker node 2
        k3s-agent-02 = { name, nodes, pkgs, ... }: {
          deployment = {
            targetHost = "192.168.8.223"; 
            targetUser = "root";
            targetPort = 22;
            tags = [ "k3s" "k3s-agent" ];
          };

          imports = [
            ./modules/k3s-agent.nix
          ];

 
        fileSystems."/" = {
          device = "/dev/disk/by-uuid/bdd7d614-861b-4d90-b724-6be838ec786b";
          fsType = "ext4";
        };
          networking.hostName = "k3s-agent-02";
          
          services.k3s.serverAddr = "https://192.168.8.248:6443";
          
          system.stateVersion = "24.05";
        };
      };
    };
}
