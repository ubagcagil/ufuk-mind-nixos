# Pena ERPNext / PoS Stack

Bu klasör, Pena Cafe için ERPNext tarafındaki **sabit mimariyi**, **taşınabilir konfigürasyonu**
ve **item_code gramerini** anlatır. Amaç: Başka bir makinede veya işletmede,
aynı POS + masa + menü yapısını sadece Git repo + birkaç komutla yeniden kurabilmek.

## Dosyalar

- `stack.md`  
  UfukOS (NixOS) → Docker stack → ERPNext site katmanlarını anlatır.  
  - `erpnext-docker.service`  
  - `/srv/erpnext/pwd.yml`  
  - `sites`, `logs` named volume’ları  
  - Pena config path’leri:
    - Host: `/srv/erpnext/config`
    - Container: `/home/frappe/frappe-bench/sites/pena-config`

- `config-genome.md`  
  Pena Cafe’nin “genom” yapısını açıklar:  
  - `config/items/` → Item listeleri (Item)  
  - `config/pos/` → POS profilleri (POS Profile)  
  - `config/restaurant/` → Restaurant Table ve ilgili objeler  
  ve bunların `bench data-import` ile nasıl içeri alınacağı.

- `item-codec.md`  
  İçecek & yiyecekler için **item_code grameri**:  
  - Espresso bazlı içecekler için: `DEPT_GROUP_BASE_SHOT_SYRUP_MILK`  
  - Türk kahvesi için ayrı profil: `DEPT_GROUP_TRK_SHOT_SWEET`  
  Bu dosya hem insanın okuyabileceği, hem makinenin parse edebileceği şekilde
  kodların anlamını tanımlar. (Şu an için v0 taslak; ERPNext’teki gerçek Item’larla
  düzenli olarak karşılaştırılmalı.)

## Kanonik referans

Bu klasördeki dokümanlar, `/srv/erpnext` altındaki runtime kopyalar yerine
**kanonik kaynak** kabul edilir.

- Runtime klasörler:
  - `/srv/erpnext`
  - `/srv/erpnext/config`
- Beyin / dokümantasyon:
  - `/etc/nixos/erpnext` (bu repo, git + GitHub ile version control altında)

Yeni bir makinede Pena ERP stack’ini anlamak isteyen kişi, önce bu dosyadan
başlamalıdır.
