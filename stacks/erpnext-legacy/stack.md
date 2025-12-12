# Pena ERPNext Stack (Production)

## 0. Big picture

- OS layer (UfukOS / NixOS):
  - Config repo: /etc/nixos (flake, git)
  - Service: erpnext-docker.service (Docker stack'i yönetir)

- App layer (ERP stack):
  - Root: /srv/erpnext
  - Compose file: /srv/erpnext/pwd.yml
  - Named volumes:
    - sites  → /home/frappe/frappe-bench/sites (DB + files)
    - logs   → /home/frappe/frappe-bench/logs

- Pena config layer (genom):
  - Host path:      /srv/erpnext/config
  - Container path: /home/frappe/frappe-bench/sites/pena-config
  - Layout:
    - config/items/
    - config/pos/
    - config/restaurant/

## 1. Stack'i başlat / durdur

# Tüm servisleri başlat
docker compose -f pwd.yml up -d

# Tüm servisleri durdur
docker compose -f pwd.yml down

## 2. Backend shell ve bench alias

# Geçici alias (bu shell için)
alias erp-bench='docker compose -f /srv/erpnext/pwd.yml exec backend bench'

# Backend container içine gir
docker compose -f pwd.yml exec -it backend bash

## 3. Site adları (container içinde)

cd /home/frappe/frappe-bench/sites
ls -1

# Örnek çıktı:
# apps.json
# apps.txt
# assets
# common_site_config.json
# frontend   ← aktif site
# pena-config

Aktif site: `frontend`

## 4. Pena config dosyaları (host)

Host:
  /srv/erpnext/config/items
  /srv/erpnext/config/pos
  /srv/erpnext/config/restaurant

Container (backend):
  /home/frappe/frappe-bench/sites/pena-config/items
  /home/frappe/frappe-bench/sites/pena-config/pos
  /home/frappe/frappe-bench/sites/pena-config/restaurant

Bu klasörlere ileride:
- Item listeleri (items.csv)
- POS profili (pos_profile.csv)
- Restoran masaları (restaurant_table.csv)
gibi CSV'ler koyulacak ve `bench data-import` ile içeri alınacak.

