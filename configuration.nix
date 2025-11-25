{ config, pkgs, ... }:

{
  # Tek görev: gerçek konfigürasyonu host modülünden çekmek.
  imports = [
    ./hosts/ufuk-desktop.nix
  ];
}
