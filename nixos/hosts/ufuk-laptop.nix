{ config, pkgs, ... }:

{
  ################################
  # Donanım + ortak modül
  ################################
  imports = [
    ../hardware/ufuk-laptop.nix
    ../modules/common.nix
  ];

  ################################
  # Hostname
  ################################
  networking.hostName = "ufuk-laptop";

  ################################
  # Laptop'a özel servis/bloat ayarları
  ################################
  services.printing.enable = false;       # Yazıcı yoksa kapalı
  services.packagekit.enable = false;     # GNOME Software backend kapalı
  services.avahi.enable = false;          # mDNS vs. kapalı

  ################################
  # Ek paketler (common + brave)
  ################################
  environment.systemPackages = with pkgs; [
    brave
  ];

  ################################
  # Log & RAM & Güç (sadece laptop)
  ################################
  services.journald.extraConfig = ''
    SystemMaxUse=200M
    SystemMaxFileSize=10M
    MaxFileSec=1month
  '';

  zramSwap.enable = true;
  zramSwap.memoryPercent = 25;

  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  ################################
  # WireGuard: ufuk-laptop (client)
  ################################
  networking.wireguard.enable = true;

  networking.wireguard.interfaces.wg0 = {
    # ufuk-laptop için VPN IP'si
    ips = [ "10.10.0.2/24" ];

    privateKeyFile = "/etc/wireguard/wg0-privkey";

    peers = [
      {
        # SERVER (ufuk-desktop) public key
        publicKey = "RskMRBCC7YCWv9cUYVVPpJx+6bH49wOKMm0IZGCfuFk=";

        # Bu tünel üzerinden erişilecek adresler
        allowedIPs = [ "10.10.0.0/24" ];

        # Şu anki endpoint'in ne olduğunu biliyorsun:
        # İster LAN IP (192.168.1.11:51820)
        # ister public IP:PORT kullanabilirsin.
        endpoint = "159.146.11.175:51820";

        persistentKeepalive = 25;
      }
    ];
  };

  ################################
  # SSH: sadece VPN + localhost
  ################################
  services.openssh.listenAddresses = [
    { addr = "10.10.0.2"; port = 22; }
    { addr = "127.0.0.1"; port = 22; }
  ];


  ################################
  # State version
  ################################
  system.stateVersion = "25.05";
}
