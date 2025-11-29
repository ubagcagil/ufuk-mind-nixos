# Pena ERP Config (Genom)

Bu klasör, Pena Cafe'nin ERPNext içindeki *taşınabilir konfigürasyonu* için kullanılır.
Amaç: Başka bir makinede veya işletmede aynı POS + masa + menü yapısını
sadece CSV dosyaları ve birkaç komutla yeniden kurabilmek.

## 0. Katmanlar

- OS / UfukOS:
  - NixOS flake, /etc/nixos
  - erpnext-docker.service → Docker stack

- App:
  - /srv/erpnext/pwd.yml → ERP stack compose dosyası
  - "sites" volume → ERPNext site verileri (DB + files)

- Business / Pena genom:
  - Bu klasör: /srv/erpnext/config
  - Container içi path: /home/frappe/frappe-bench/sites/pena-config

## 1. Dizin yapısı

- config/items/
  - Ürün tanımları (Item)
  - Örnek: items.csv
- config/pos/
  - POS profilleri (POS Profile)
  - Örnek: pos_profiles.csv
- config/restaurant/
  - Restoran masaları ve ilgili objeler (Restaurant Table)
  - Örnek: restaurant_tables.csv

## 2. CSV prensipleri

- Tüm CSV'ler ERPNext'in Data Import template'lerinden türetilir.
- Kolon başlıklarını ERPNext verir; biz sadece satırları (veriyi) doldururuz.
- Her dosya "tek tablo / tek DocType" prensibini izler:
  - items.csv          → DocType: Item
  - pos_profiles.csv   → DocType: POS Profile
  - restaurant_tables.csv → DocType: Restaurant Table

## 3. Import komut iskeleti (not: site adı örnek)

Host'ta:

  cd /srv/erpnext
  alias erp-bench='docker compose -f /srv/erpnext/pwd.yml exec backend bench'
  SITE=frontend    # gerçek site adını ls sites çıktısına göre ayarla

Örnek import komutları (CSV dosyaları hazır olduktan sonra):

  # Restaurant masaları
  erp-bench --site "$SITE" data-import \
    --file "pena-config/restaurant/restaurant_tables.csv" \
    --doctype "Restaurant Table" \
    --type Insert

  # Ürünler
  erp-bench --site "$SITE" data-import \
    --file "pena-config/items/items.csv" \
    --doctype "Item" \
    --type Insert

  # POS profilleri
  erp-bench --site "$SITE" data-import \
    --file "pena-config/pos/pos_profiles.csv" \
    --doctype "POS Profile" \
    --type Insert

Bu dosya *sadece şemayı* açıklar; gerçek veriler ilgili klasörlerdeki CSV'lerde tutulur.
