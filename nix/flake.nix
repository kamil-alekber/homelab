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
            ./hosts/storage/configuration.nix
            ./modules/samba.nix
          ];

          networking.hostName = "storage-01";
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
            ./hosts/k3s-nodes/server-1/configuration.nix
            ./modules/k3s-server.nix
            
          ];

          networking.hostName = "k3s-server-01";
        };

        k3s-server-02 = { name, nodes, pkgs, ... }: {
          deployment = {
            targetHost = "192.168.8.182"; # Change to your IP
            targetUser = "root";
            targetPort = 22;
            tags = [ "k3s" "k3s-server" ];
          };

          imports = [
            ./hosts/k3s-nodes/server-2/configuration.nix
            ./modules/k3s-server.nix
            
          ];

          networking.hostName = "k3s-server-02";
        };

        k3s-server-03 = { name, nodes, pkgs, ... }: {
          deployment = {
            targetHost = "192.168.8.103"; # Change to your IP
            targetUser = "root";
            targetPort = 22;
            tags = [ "k3s" "k3s-server" ];
          };

          imports = [
            ./hosts/k3s-nodes/server-3/configuration.nix
            ./modules/k3s-server.nix
          ];

          networking.hostName = "k3s-server-03";
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
            ./hosts/k3s-nodes/worker-1/configuration.nix
            ./modules/k3s-agent.nix
          ];

          networking.hostName = "k3s-agent-01";
          
          services.k3s.serverAddr = "https://192.168.8.248:6443";
        };

        # K3s worker node 2
        k3s-agent-02 = { name, nodes, pkgs, ... }: {
          deployment = {
            targetHost = "192.168.8.195"; 
            targetUser = "root";
            targetPort = 22;
            tags = [ "k3s" "k3s-agent" ];
          };

          imports = [
            ./hosts/k3s-nodes/worker-2/configuration.nix
            ./modules/k3s-agent.nix
          ];

          networking.hostName = "k3s-agent-02";
          
          services.k3s.serverAddr = "https://192.168.8.248:6443";
        };
      };
    };
}
