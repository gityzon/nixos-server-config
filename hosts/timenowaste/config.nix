{
  config,
  pkgs,
  host,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware.nix
  ];

  boot.kernelParams = [
    # 关闭内核的操作审计功能
    "audit=0"
    # 不要根据 PCIe 地址生成网卡名（例如 enp1s0，对 VPS 没用），而是直接根据顺序生成（例如 eth0）
    "net.ifnames=0"
  ];

  # 开启 ZSTD 压缩和基于 systemd 的第一阶段启动
  boot.initrd = {
    compressor = "zstd";
    compressorArgs = ["-19" "-T0"];
    systemd.enable = true;
  };

  boot = {
    # Kernel
    kernelPackages = pkgs.linuxPackages_zen;
    # Bootloader.
    # loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.grub = {
      enable = !config.boot.isContainer;
      default = "saved";
      device = "/dev/vda";
      useOSProber = true;
    };
    # Make /tmp a tmpfs
    tmp = {
      useTmpfs = false;
      tmpfsSize = "30%";
    };
  };

  swapDevices = [{ device = "/swapfile"; size = 1024; }];
  # Enable networking
  # networking.networkmanager.enable = true;
  networking.hostName = host;

  # Set your time zone.
  time.timeZone = "Asia/Singapore";

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
    mutableUsers = false;
    users.root = {
      hashedPassword = "$y$j9T$lBFX/Lh4ssVXJwn.L4Bj80$rb5uRZthWPbL9JIisphZyFwScrcOXizYAwRRDe7.eS7";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhtWgRmVXptkc7cVosLt5juqaaj4Ce8I5WAvmp8IyAG"
      ];
  };
  };

  # 使用 systemd-networkd 管理网络
  systemd.network.enable = true;
  services.resolved.enable = false;

  networking.nameservers = [
    "1.1.1.1"
  ];

  environment.systemPackages = with pkgs; [
    curl
    fastfetch
    git
    netcat-gnu
    micro
    wget
  ];

   # Services to start
  services.openssh = {
    enable = true;
    ports = [ 222 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
      UseDns = false;
      X11Forwarding = false;
      PermitRootLogin = "yes"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
    };
  };
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
