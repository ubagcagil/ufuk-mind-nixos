{ config, pkgs, ... }:

let
  host = config.networking.hostName;
in
{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "sys-update" ''
      set -euo pipefail

      FLAKE=/etc/nixos
      TARGET="${host}"

      if [ -z "$TARGET" ]; then
        echo "sys-update: networking.hostName is empty" >&2
        exit 1
      fi

      if [ "$(id -u)" -ne 0 ]; then
        exec sudo nixos-rebuild switch --flake "$FLAKE#$TARGET" "$@"
      else
        exec nixos-rebuild switch --flake "$FLAKE#$TARGET" "$@"
      fi
    '')
  ];
}

