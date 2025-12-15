# Yeni host ekleme (v1)

## Amaç
Yeni bir makineyi (örn. ufuk-mini) aynı repo ile kurmak.

## Adımlar (özet)
1) Host klasörü aç: `nixos/hosts/<hostname>/`
2) Donanım config’i ekle (genelde installer’ın ürettiği hardware-configuration.nix).
3) Host entrypoint’ini flake çıktısına bağla.
4) `nix flake check` ve `nixos-rebuild build` ile doğrula.
