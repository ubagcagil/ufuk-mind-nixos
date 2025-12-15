# Rollback

## Generations listele
- `sudo nix-env -p /nix/var/nix/profiles/system --list-generations`

## Bir önceki generation’a dön
- `sudo nixos-rebuild switch --rollback`
