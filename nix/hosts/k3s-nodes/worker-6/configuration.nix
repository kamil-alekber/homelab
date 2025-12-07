# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # networking.hostName is set in flake.nix
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Almaty";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "kk_KZ.UTF-8";
    LC_IDENTIFICATION = "kk_KZ.UTF-8";
    LC_MEASUREMENT = "kk_KZ.UTF-8";
    LC_MONETARY = "kk_KZ.UTF-8";
    LC_NAME = "kk_KZ.UTF-8";
    LC_NUMERIC = "kk_KZ.UTF-8";
    LC_PAPER = "kk_KZ.UTF-8";
    LC_TELEPHONE = "kk_KZ.UTF-8";
    LC_TIME = "kk_KZ.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.openssh = {
    enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kamil = {
    isNormalUser = true;
    description = "Kamil";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrbzy02WnDwoYuJuf/9t/DVOHqtXpsESLhmplbUnQ1dUcko3++kqO1zpFP2hq/RRhhoJRvn72C925+IyLT1gV2nJvsu2k1SQxfHD4fKeCCdSK8pqzH2Oi2S7NC4M6P2vtRq27BVEAwuQlnFbYq4DfNqqZaIpOVkjqvMQkLy3TvqVvMQ0B9dexBL3+MlOGSlplLjPrtLIeSZfOJEJtREFXMUpKUy5TDC6405YmIAGBivRHmTRKp7Vy9r/VfcJGy23U0eGsl76e3MYoLShT78Rb9tWof5TWATlAMt//MBMpQxMRS8RbWWdg1xqXePJUyq8jGjAMRqNHw5xITp73hH3C4Mrl61MCDViJ3ZAdpLTY4lFHbSMj84chPtWy0etWCIKepVo54pMYdTBFpec49d24JoMSCiQEW8EN3nohfr2IpyDMW8vISeXlhATpTyJSMgdv/K/8Zv2ARQiXspr2JGVDlW4JyJ/ro0lrh9CVy9sqg+WwJAk3rG52Q/QdZuS9cqDK37qTKjcYD7M7wV6vraAJ36eJhMJ0mq0n56RMpTj3r265BMWEMUpqCtURDYYLQUSLrm/Y+obiSc7KpyyocC1mmP/qZtYJOR3Swt6GHlZq4KGTfikHijG3ULW3p6mu1j+bevrvmGlFqGajSUSJ9Js2pDa7iqLnNlAamCCaxrPgo+Q== kamil.alekber@gmail.com"     
  ]; 
 };
  users.users.root = {
     openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrbzy02WnDwoYuJuf/9t/DVOHqtXpsESLhmplbUnQ1dUcko3++kqO1zpFP2hq/RRhhoJRvn72C925+IyLT1gV2nJvsu2k1SQxfHD4fKeCCdSK8pqzH2Oi2S7NC4M6P2vtRq27BVEAwuQlnFbYq4DfNqqZaIpOVkjqvMQkLy3TvqVvMQ0B9dexBL3+MlOGSlplLjPrtLIeSZfOJEJtREFXMUpKUy5TDC6405YmIAGBivRHmTRKp7Vy9r/VfcJGy23U0eGsl76e3MYoLShT78Rb9tWof5TWATlAMt//MBMpQxMRS8RbWWdg1xqXePJUyq8jGjAMRqNHw5xITp73hH3C4Mrl61MCDViJ3ZAdpLTY4lFHbSMj84chPtWy0etWCIKepVo54pMYdTBFpec49d24JoMSCiQEW8EN3nohfr2IpyDMW8vISeXlhATpTyJSMgdv/K/8Zv2ARQiXspr2JGVDlW4JyJ/ro0lrh9CVy9sqg+WwJAk3rG52Q/QdZuS9cqDK37qTKjcYD7M7wV6vraAJ36eJhMJ0mq0n56RMpTj3r265BMWEMUpqCtURDYYLQUSLrm/Y+obiSc7KpyyocC1mmP/qZtYJOR3Swt6GHlZq4KGTfikHijG3ULW3p6mu1j+bevrvmGlFqGajSUSJ9Js2pDa7iqLnNlAamCCaxrPgo+Q== kamil.alekber@gmail.com"
    ];
  
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
