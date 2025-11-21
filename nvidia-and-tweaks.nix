{ config, pkgs, lib, ... }:

{
  ##########################
  # NVIDIA sürücüsü
  ##########################
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;          # RTX 4090 için proprietary driver
    nvidiaSettings = true; # nvidia-settings aracı
  };

  ##########################
  # Araçlar
  ##########################
  environment.systemPackages = with pkgs; [
    pciutils
  ];
}

