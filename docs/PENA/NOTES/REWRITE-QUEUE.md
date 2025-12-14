# Rewrite Queue (Pena + ERP)

Bu dosya, eski dokümanları “silmeden” yeni fikirlerle temiz şekilde yeniden yazma planımızdır.
Kural: Bir şeyi yeniden yazmadan önce eskisini `docs/PENA/NOTES/LEGACY/<date>/` altına taşırız.

## Çalışma kuralı
- Tek bir oturum = 1–3 küçük PR/commit (küçük, okunabilir, geri alınabilir).
- “Canonical” dokümanlar kısa ve nettir; detaylar NOTES altına gider.
- Secrets yok: Token/şifre/anahtar/asla repo’ya girmez.

## Kuyruk
Durum: `todo | drafting | review | done`

| ID | Konu | Kaynak (legacy) | Hedef (canonical) | Not | Durum |
|---:|------|------------------|-------------------|-----|-------|
| 1 | Pena manifesto / amaç | (taşınacak) | docs/PENA/README.md | 1 sayfa; net değer önerisi | todo |
| 2 | House rules (mekân kuralları) | (taşınacak) | docs/PENA/HOUSE/README.md | “nasıl bir yer?” | todo |
| 3 | Dijital altyapı prensipleri | (taşınacak) | docs/PENA/ARCH/README.md | minimal + sürdürülebilir | todo |
| 4 | ERPNext çalışma modeli | (taşınacak) | docs/PENA/ERP/README.md | iş akışları + sınırlar | todo |
| 5 | ERPNext operasyon runbook | stacks/erpnext/README.md | stacks/erpnext/README.md | zaten var; sadeleştirilecek | todo |
| 6 | URY entegrasyon notları | (taşınacak) | docs/PENA/ERP/URY.md | sadece gerekli olan | todo |

## Notlar
- “Kaynak (legacy)” kısmını, taşıma sonrası gerçek dosya path’i ile dolduracağız.
