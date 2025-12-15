{ config, pkgs, lib, ... }:

{
  ################################
  # Donanım + ortak modül
  ################################
  imports = [
    ./hardware.nix
    ../../modules/hardware/nvidia-and-tweaks.nix
    ../../modules/common.nix
    ../../modules/erpnext-docker.nix
    ../../modules/erpnext-backup.nix
    ../../modules/core/sys-update.nix
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
  # Desktop: NetworkManager kapalı, DHCP yok
  ################################
  networking.networkmanager.enable = lib.mkForce false;
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;

  ################################
  # Statik LAN IP (server)
  ################################
  networking.interfaces.enp5s0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "192.168.1.11";
        prefixLength = 24;
      }
    ];
  };

  networking.defaultGateway = "192.168.1.1";

  networking.nameservers = [
    "192.168.1.1"
    "1.1.1.1"
  ];

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
  # Firewall: server portları
  ################################
  # 22  : SSH (sadece localhost + VPN)
  # 8080: ERPNext (lokal/VPN üzerinden)
  networking.firewall.allowedTCPPorts = [ 22 8080 ];
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.trustedInterfaces = [ "wg0" ];

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
  # SSH: Sadece VPN + localhost
  ################################
  services.openssh.listenAddresses = [
    { addr = "10.10.0.1"; port = 22; }
    { addr = "127.0.0.1"; port = 22; }
  ];

  ################################
  # Cloudflare Tunnel: pena-erp
  ################################
  environment.etc."cloudflared/config.yml".text = ''
    tunnel: ea6d9fd4-2eaf-4b5e-a992-c62e313c45b6
    credentials-file: /home/ubagcagil/.cloudflared/ea6d9fd4-2eaf-4b5e-a992-c62e313c45b6.json

    ingress:
      - hostname: erp.penacafekarakoy.com
        service: http://localhost:8080
      - service: http_status:404
  '';

  systemd.services."cloudflared-pena-erp" = {
    description = "Cloudflare Tunnel for Pena ERP";
    after = [ "network-online.target" "docker.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "ubagcagil";
      Group = "users";
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared --config /etc/cloudflared/config.yml tunnel run pena-erp";
      Restart = "always";
      RestartSec = 5;
    };
  };

 ############
 #ERP BACKUP
 #############
 
 environment.etc."erpnext-backup.conf" = {
    text = ''
      ERP_DIR=/srv/erpnext
      COMPOSE_FILE=pwd.yml
      SERVICE=backend
      SITE=frontend
      BACKUP_DIR=/srv/erpnext-backups
    '';
    mode = "0640";
  };

  ################################
  # State version
  ################################
  system.stateVersion = "25.05";
}
