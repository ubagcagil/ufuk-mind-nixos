# sys-update (tek komut güncelleme)

## Amaç
Hostname’e göre doğru flake hedefiyle sistemi güncellemek.

## Komut
1) Repoyu güncelle:
   - `cd /etc/nixos && git pull`
2) Güncelle:
   - `sys-update`

## sys-update yoksa (fallback)
- `sudo nixos-rebuild switch --flake /etc/nixos#$(hostname)`

## Notlar
- “Git tree is dirty” uyarısı: commit edilmemiş değişiklik var demek.
