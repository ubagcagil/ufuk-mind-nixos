# DR: Host restore (bare metal)

## Senaryo
Disk gitti / sistem açılmıyor / yeniden kurulum gerekiyor.

## Adımlar (yüksek seviye)
1) NixOS installer ile boot et.
2) Disk bölümlendir + mount et (senin disk düzenine göre).
3) `/mnt/etc/nixos` altına repoyu koy:
   - git ile clone veya elindeki kopyayı taşı.
4) Kur:
   - `nixos-install --flake /mnt/etc/nixos#<hostname>`
5) Reboot.

## Restore sonrası kontrol
- `sys-update`
- `systemctl --failed`
- ağ/ssh erişimi
