# ERPNext (URY) Stack Runbook

Bu klasör, ufuk-desktop üzerindeki ERPNext/Frappé kurulumunun (Docker Compose) operasyon rehberidir.
Amaç: “nasıl çalıştırılır / nasıl bakımı yapılır / nasıl geri yüklenir” sorularının tek cevabı olsun.

> Secrets politikası: `docs/SECRETS.md` (bu repoya secret girmez).

---

## 1) Mimari / Bileşenler

**Host path:** `/srv/erpnext`  
**Compose:** `/srv/erpnext/pwd.yml`  
**Image:** `pena/erpnext-ury:v15` (backend/frontend/worker/scheduler/websocket aynı image)

Servisler (özet):
- `frontend` : Nginx (8080) – web entry
- `backend`  : Gunicorn (8000) – frappe app
- `websocket`: socketio (9000)
- `queue-short`, `queue-long`, `scheduler`
- `db` (MariaDB 10.6), `redis-cache`, `redis-queue`
- `configurator`, `create-site` (ilk kurulum akışında)

---

## 2) Hızlı Komutlar (en sık)

### Stack kontrol
```bash
cd /srv/erpnext
docker compose -f pwd.yml ps
docker compose -f pwd.yml logs -f --tail=200 frontend
docker compose -f pwd.yml logs -f --tail=200 backend


Start / Stop
cd /srv/erpnext
docker compose -f pwd.yml up -d
docker compose -f pwd.yml down

Backend shell + bench
cd /srv/erpnext
docker compose -f pwd.yml exec backend sh
# içeride:
cd /home/frappe/frappe-bench
bench --site frontend list-apps
bench --site frontend doctor

Asset sanity (CSS/JS 200 olmalı)
BASE=http://localhost:8080
curl -sI "$BASE/" \
| awk -F'[<>]' '/^Link:/{for(i=2;i<=NF;i+=2) print $i}' \
| while read -r p; do echo "Testing $p"; curl -sI "$BASE$p" | head -n 1; done

4) “CSS 404 / ham HTML” tipi sorunlar

Belirti:

Sayfa ham HTML gibi gelir, CSS 404 olur.

Kök neden (bu stack’te yaşandı):

Frontend container içinde apps/.../public/dist dosyaları backend ile senkron değilse,
Nginx doğru dosyayı bulamaz ve CSS 404 üretir.

Hızlı teşhis:

cd /srv/erpnext
BASE=http://localhost:8080

CSS_PATHS=$(curl -sI "$BASE/" \
  | awk -F'[<>]' '/^Link:/{for(i=2;i<=NF;i+=2) if($i ~ /^\/assets\// && $i ~ /\.css$/) print $i}')

for p in $CSS_PATHS; do
  echo "== $p =="
  for svc in frontend backend; do
    docker compose -f pwd.yml exec "$svc" sh -lc \
      "test -f /home/frappe/frappe-bench/sites$p && echo $svc:OK || echo $svc:MISS"
  done
done


Kalıcı hedef:

Frontend + backend’in aynı build output (dist) görmesi.

Compose tarafında “sites/assets’a ayrı volume” gibi ayrıştırıcı şeylerden kaçınmak.

Image build aşamasında assets üretimi + container’larda tutarlı filesystem.

Not:

Bu repo içinde “fix yöntemi” değiştiyse, burayı güncelle (hangi kalıcı yöntem seçildiyse).

5) Backup sistemi (host systemd)

Backuplar host üzerinde systemd timer/service ile alınır.

Servisler:

erpnext-backup-daily

erpnext-backup-weekly

erpnext-backup-monthly

erpnext-backup-quarterly

Çıktı dizini:

/srv/erpnext-backups

Durum:

systemctl list-timers --all --no-pager | grep erpnext-backup || true
sudo systemctl status erpnext-backup-weekly --no-pager -n 50


Manuel çalıştırma:

sudo systemctl start erpnext-backup-daily
sudo systemctl start erpnext-backup-weekly
sudo systemctl start erpnext-backup-monthly
sudo systemctl start erpnext-backup-quarterly


Doğrulama:

sudo ls -lah /srv/erpnext-backups
sudo gzip -t /srv/erpnext-backups/erpnext-daily.sql.gz && echo OK-daily
sudo gzip -t /srv/erpnext-backups/erpnext-weekly.sql.gz && echo OK-weekly
sudo gzip -t /srv/erpnext-backups/erpnext-monthly.sql.gz && echo OK-monthly
sudo gzip -t /srv/erpnext-backups/erpnext-quarterly.sql.gz && echo OK-quarterly

6) Restore (yüksek dikkat)

Bu bölüm “gerektiğinde” kullanılır; restore işi risklidir.

Genel yaklaşım:

Stack’i durdur (docker compose down)

DB restore (sql.gz) + dosyaları geri koy

Stack’i kaldır

Öneri: restore prosedürünü uygulamadan önce bu dosyaya “adım adım restore playbook” ekle
(ekran çıktıları ve hangi komutların nerede koştuğu dahil).

6) Restore (yüksek dikkat)

Bu bölüm “gerektiğinde” kullanılır; restore işi risklidir.

Genel yaklaşım:

Stack’i durdur (docker compose down)

DB restore (sql.gz) + dosyaları geri koy

Stack’i kaldır

Öneri: restore prosedürünü uygulamadan önce bu dosyaya “adım adım restore playbook” ekle
(ekran çıktıları ve hangi komutların nerede koştuğu dahil).

7) NixOS güncelleme

Sistem config güncellemesi:

sys-update (flake + hostname seçimi ile rebuild/switch)

Not:

/etc/nixos git tree dirty uyarısı normal; ama üretim değişikliklerinde commit’lemek tercih edilir.

8) İlgili dokümanlar

Yaşam ağacı: docs/LIFE-TREE.md

Şu an / bir sonraki hedef: docs/NOW.md

Secrets politikası: docs/SECRETS.md
