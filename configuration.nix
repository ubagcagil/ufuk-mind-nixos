{ config, pkgs, ... }:

{
  ################################
  # Donanım ve boot
  ################################
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ################################
  # Hostname + network
  ################################
  networking.hostName = "ufuk-desktop";
  networking.networkmanager.enable = true;

  # Firewall: SSH (22/tcp) + WireGuard (51820/udp)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 51820 ];

    # WireGuard tüneli güvenilir arayüz: laptop'tan gelen trafiğe izin ver
    trustedInterfaces = [ "wg0" ];
    allowPing = true;
  };

  # WireGuard istemcileri için NAT (wg0 -> enp5s0 üzerinden internete çıksın)
  networking.nat = {
    enable = true;
    externalInterface = "enp5s0";
    internalInterfaces = [ "wg0" ];
  };

  # Ek garanti: IPv4 forwarding
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Docker (ERPNext vs için zemin)
  virtualisation.docker.enable = true;

  ################################
  # Saat, locale, klavye
  ################################
  time.timeZone = "Europe/Istanbul";

  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  # GNOME + X11
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # X11 klavye: Türkçe Q
  services.xserver.xkb = {
    layout = "tr";
    variant = "";
  };

  # Konsol (TTY) klavye
  console.keyMap = "trq";

  ################################
  # NVIDIA / RTX 4090
  ################################
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;          # 4090 için proprietary driver
    nvidiaSettings = true; # nvidia-settings aracı
  };

  ################################
  # Ses: PipeWire
  ################################
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ################################
  # Kullanıcı
  ################################
  users.users.ubagcagil = {
    isNormalUser = true;
    description = "Ufuk Berk Agcagil";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ ];
  };

  # GNOME otomatik login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "ubagcagil";

  # GNOME autologin workaround
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  ################################
  # Global paketler
  ################################
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    pciutils         # lspci
    usbutils         # lsusb
    htop
    git
    curl
    wget
    zip
    unzip
    nano
    wireguard-tools  # VPN için
  ];

  ################################
  # SSH sunucu
  ################################
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  ################################
  # WireGuard: ufukdesktop (server)
  ################################
  networking.wireguard.enable = true;
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.10.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/etc/wireguard/wg0-privkey";

    peers = [
      {
        # Laptop peer
        publicKey = "xMFEFKGQL6Hi46xT/OzKD6wyEbG7r9dMUPEackQO1Xo=";
        allowedIPs = [ "10.10.0.2/32" ];
        persistentKeepalive = 25;
      }
    ];
  };

  ################################
  # State version
  ################################
  system.stateVersion = "25.05";
}
