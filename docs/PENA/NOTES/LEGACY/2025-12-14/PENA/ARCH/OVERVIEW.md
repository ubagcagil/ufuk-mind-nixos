# Digital Architecture Overview

## Bileşenler
- NixOS flake tabanlı sistem tanımı: `/etc/nixos`
- Hostlar:
  - ufuk-desktop (server/homelab)
  - ufuk-laptop (client)
- Stacks:
  - ERPNext (Docker Compose): `/srv/erpnext`

## Operasyon prensipleri
- Tek komut güncelleme: `sys-update`
- Backup: systemd timer + rotate lanes (daily/weekly/monthly/quarterly)
- Logs: sorun anında tek yerden bakılabilir olmalı.
