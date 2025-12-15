# DR: ERPNext restore

## Senaryo
ERPNext stack bozuldu / containerlar kalkmıyor / DB geri dönmeli.

## Kaynaklar
- `stacks/erpnext/` altındaki runbook ve backup prosedürü (hedef: tek gerçek kaynak).

## Genel akış
1) Servisleri durdur
2) Backup’tan DB + site restore
3) Servisleri kaldır
4) Smoke test (login, site assets, job queue)
