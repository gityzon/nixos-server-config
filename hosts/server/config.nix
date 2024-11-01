{
  config,
  pkgs,
  host,
  ...
}:
{
  imports = [
    ./hardware.nix
  ];

  boot = {
    # Kernel
    kernelPackages = pkgs.linuxPackages_zen;
    # Bootloader.
    # loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.grub = {
      enable = true;
      device = "/dev/vda";
      useOSProber = true;
    };
    # Make /tmp a tmpfs
    tmp = {
      useTmpfs = false;
      tmpfsSize = "30%";
    };
  };

  swapDevices = [{ device = "/swapfile"; size = 1075; }];
  # Enable networking
  # networking.networkmanager.enable = true;
  networking.hostName = host;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

 nixpkgs.config.allowUnfree = true;

  users = {
    mutableUsers = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    micro
    wget
    curl
    git
    fastfetch
    kubectl
    kubernetes-helm
  ];

  environment.variables = {
  #   ZANEYOS_VERSION = "2.2";
  #   ZANEYOS = "true";
      KUBECONFIG = /etc/rancher/k3s/k3s.yaml;
  };

   # Services to start
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = false;
      X11Forwarding = false;
      PermitRootLogin = "yes"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };
  # first server
  services.k3s = {
    enable = true;
    role = "server";
    package = pkgs.k3s_1_30;
  };
  # another
  # services.k3s = {
  #   enable = true;
  #   role = "server"; # Or "agent" for worker only nodes
  #   token = "<randomized common secret>";
  #   serverAddr = "https://<ip of first node>:6443";
  # };
  # Optimization settings and garbage collection automation
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Virtualization / Containers
  # virtualisation.libvirtd.enable = true;
  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;
  #   defaultNetwork.settings.dns_enabled = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
