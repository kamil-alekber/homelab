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
            targetHost = "192.168.1.20"; # Change to your IP
            targetUser = "root";
            targetPort = 22;
            tags = [ "storage" ];
          };

          imports = [
            ./modules/samba.nix
          ];

          networking.hostName = "storage-01";
          
          # System configuration
          system.stateVersion = "24.05";
        };

        # K3s control plane node
        k3s-server-01 = { name, nodes, pkgs, ... }: {
          deployment = {
            targetHost = "192.168.1.21"; # Change to your IP
            targetUser = "root";
            targetPort = 22;
            tags = [ "k3s", "k3s-server" ];
          };

          imports = [
            ./modules/k3s-server.nix
          ];

          networking.hostName = "k3s-server-01";
          
          system.stateVersion = "24.05";
        };

        # K3s worker node 1
        k3s-agent-01 = { name, nodes, pkgs, ... }: {
          deployment = {
            targetHost = "192.168.1.22"; # Change to your IP
            targetUser = "root";
            targetPort = 22;
            tags = [ "k3s", "k3s-agent" ];
          };

          imports = [
            ./modules/k3s-agent.nix
          ];

          networking.hostName = "k3s-agent-01";
          
          # Reference the server node
          services.k3s.serverAddr = "https://${nodes.k3s-server-01.config.networking.hostName}:6443";
          
          system.stateVersion = "24.05";
        };

        # K3s worker node 2
        k3s-agent-02 = { name, nodes, pkgs, ... }: {
          deployment = {
            targetHost = "192.168.1.23"; # Change to your IP
            targetUser = "root";
            targetPort = 22;
            tags = [ "k3s", "k3s-agent" ];
          };

          imports = [
            ./modules/k3s-agent.nix
          ];

          networking.hostName = "k3s-agent-02";
          
          # Reference the server node
          services.k3s.serverAddr = "https://${nodes.k3s-server-01.config.networking.hostName}:6443";
          
          system.stateVersion = "24.05";
        };
      };
    };
}
