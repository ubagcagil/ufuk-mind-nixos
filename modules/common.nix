{ config, pkgs, ... }:

{

  ################################
  # Boot
  ################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 8;

  ################################
  # Ağ: NetworkManager + Firewall
  ################################
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowPing = true;
  };


  ################################
  # Avahi (mDNS) kapalı
  ################################
  services.avahi.enable = false;

  ################################
  # Docker
  ################################
  virtualisation.docker.enable = true;

  ################################
  # Saat, locale
  ################################
  time.timeZone = "Europe/Istanbul";

  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT    = "tr_TR.UTF-8";
    LC_MONETARY       = "tr_TR.UTF-8";
    LC_NAME           = "tr_TR.UTF-8";
    LC_NUMERIC        = "tr_TR.UTF-8";
    LC_PAPER          = "tr_TR.UTF-8";
    LC_TELEPHONE      = "tr_TR.UTF-8";
    LC_TIME           = "tr_TR.UTF-8";
  };

  ################################
  # GNOME + X11 + Klavye
  ################################
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "tr";
    variant = "";
  };

  # Konsol (TTY) klavye
  console.keyMap = "trq";

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
    cloudflared      # Cloudflare Tunnel CLI
    python3Full
    steam
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
  # Sudo: wheel grubuna şifresiz sudo
  ################################
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  ################################
  # Nix experimental features (flakes)
  ################################
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
