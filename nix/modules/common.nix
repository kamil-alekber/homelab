{ config, pkgs, lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  nix.settings.auto-optimise-store = true;

  # Boot loader (GRUB for most VMs/physical servers)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; 

  networking.useDHCP = lib.mkDefault false;
  networking.firewall.enable = true;

  networking.defaultGateway = "192.168.8.1";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  time.timeZone = "UTC";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrbzy02WnDwoYuJuf/9t/DVOHqtXpsESLhmplbUnQ1dUcko3++kqO1zpFP2hq/RRhhoJRvn72C925+IyLT1gV2nJvsu2k1SQxfHD4fKeCCdSK8pqzH2Oi2S7NC4M6P2vtRq27BVEAwuQlnFbYq4DfNqqZaIpOVkjqvMQkLy3TvqVvMQ0B9dexBL3+MlOGSlplLjPrtLIeSZfOJEJtREFXMUpKUy5TDC6405YmIAGBivRHmTRKp7Vy9r/VfcJGy23U0eGsl76e3MYoLShT78Rb9tWof5TWATlAMt//MBMpQxMRS8RbWWdg1xqXePJUyq8jGjAMRqNHw5xITp73hH3C4Mrl61MCDViJ3ZAdpLTY4lFHbSMj84chPtWy0etWCIKepVo54pMYdTBFpec49d24JoMSCiQEW8EN3nohfr2IpyDMW8vISeXlhATpTyJSMgdv/K/8Zv2ARQiXspr2JGVDlW4JyJ/ro0lrh9CVy9sqg+WwJAk3rG52Q/QdZuS9cqDK37qTKjcYD7M7wV6vraAJ36eJhMJ0mq0n56RMpTj3r265BMWEMUpqCtURDYYLQUSLrm/Y+obiSc7KpyyocC1mmP/qZtYJOR3Swt6GHlZq4KGTfikHijG3ULW3p6mu1j+bevrvmGlFqGajSUSJ9Js2pDa7iqLnNlAamCCaxrPgo+Q== kamil.alekber@gmail.com"
    ];
  };

  users.users.kamil = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDrbzy02WnDwoYuJuf/9t/DVOHqtXpsESLhmplbUnQ1dUcko3++kqO1zpFP2hq/RRhhoJRvn72C925+IyLT1gV2nJvsu2k1SQxfHD4fKeCCdSK8pqzH2Oi2S7NC4M6P2vtRq27BVEAwuQlnFbYq4DfNqqZaIpOVkjqvMQkLy3TvqVvMQ0B9dexBL3+MlOGSlplLjPrtLIeSZfOJEJtREFXMUpKUy5TDC6405YmIAGBivRHmTRKp7Vy9r/VfcJGy23U0eGsl76e3MYoLShT78Rb9tWof5TWATlAMt//MBMpQxMRS8RbWWdg1xqXePJUyq8jGjAMRqNHw5xITp73hH3C4Mrl61MCDViJ3ZAdpLTY4lFHbSMj84chPtWy0etWCIKepVo54pMYdTBFpec49d24JoMSCiQEW8EN3nohfr2IpyDMW8vISeXlhATpTyJSMgdv/K/8Zv2ARQiXspr2JGVDlW4JyJ/ro0lrh9CVy9sqg+WwJAk3rG52Q/QdZuS9cqDK37qTKjcYD7M7wV6vraAJ36eJhMJ0mq0n56RMpTj3r265BMWEMUpqCtURDYYLQUSLrm/Y+obiSc7KpyyocC1mmP/qZtYJOR3Swt6GHlZq4KGTfikHijG3ULW3p6mu1j+bevrvmGlFqGajSUSJ9Js2pDa7iqLnNlAamCCaxrPgo+Q== kamil.alekber@gmail.com"
    ];
  };

  # Allow sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;
  
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    tmux
    rsync
    inetutils
    dnsutils
    parted
  ];

  # Enable temperature monitoring
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
