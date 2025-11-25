{ config, pkgs, ... }:

{
  ################################
  # Donanım + ortak modül
  ################################
  imports = [
    ../hardware-configuration.nix
    ../modules/common.nix
  ];

  ################################
  # Hostname
  ################################
  networking.hostName = "ufuk-desktop";

  ################################
  # NAT: wg0 -> enp5s0 üzerinden internete çıksın
  ################################
  networking.nat = {
    enable = true;
    externalInterface = "enp5s0";
    internalInterfaces = [ "wg0" ];
  };

  # Ek garanti: IPv4 forwarding
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

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
  # WireGuard: ufuk-desktop (server)
  ################################
  networking.wireguard.enable = true;
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.10.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = "/etc/wireguard/wg0-privkey";

    peers = [
      {
        # Laptop peer
        publicKey = "z/qyWY14ddR7jg0+iFXCYXeZAjf/VVANJpTgmm6mNls=";
        allowedIPs = [ "10.10.0.2/32" ];
        persistentKeepalive = 25;
      }
    ];
  };

  ################################
  # Güç yönetimi – kasa ASLA uyumaya gitmesin
  ################################
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  services.logind = {
    lidSwitch = "ignore";         # laptop için de olsa zararı yok
    lidSwitchDocked = "ignore";
    extraConfig = ''
      IdleAction=ignore
      IdleActionSec=0
    '';
  };

  ################################
  # State version
  ################################
  system.stateVersion = "25.05";
}
