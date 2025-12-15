# Pena (Karaköy) — Canonical

Bu klasör, Pena’nın kültürü, işletme prensipleri ve dijital omurgası için **tek kanonik** kaynaktır.
Amaç: “Pena nedir ve nasıl yaşar?” sorusuna kısa, net cevap.

## 0) Altın Kurallar
- Müşteri verisi / finansal çıktı / DB dump / token / secret bu repoya girmez.
- Repoda sadece: metinler, prensipler, şablonlar, runbook’lar ve mimari kararlar bulunur.
- “Geçmiş arşivi” tutulmaz; sadece **şimdi** ve **yakın gelecek**.

## 1) Kültür (tek gerçek kaynak)
- Manifesto: `pena/culture/manifesto.md`
- House Rules: `pena/culture/house-rules.md`

## 2) Operasyon (minimal)
Bu repo “dokümantasyon + otomasyon” mantığıyla yaşar. Günlük operasyon checklist’leri ve sistem runbook’ları `docs/` altındadır.

- Aktif işler: `docs/NOW.md`
- Sistem runbook’ları: `docs/runbooks/`
- Felaket kurtarma: `docs/dr/`

## 3) Dijital omurga (URY / ERPNext)
Pena’nın dijital operasyonu iki katmanlıdır:
1) **NixOS layer** (host + modül): `nixos/`
2) **Runtime stack layer** (compose + script + ops): `stacks/erpnext/`

Hedef:
- ERPNext’in kurulumu/backup/restore/healthcheck işlemleri tekrarlanabilir olacak.
- “Bir gün her şey sıfırlansa bile” bu repo ile geri dönülebilecek.

## 4) Roadmap (kısa)
- URY/ERPNext: stack’i stabil hale getir (assets, backup lanes, restore test)
- Pena dijital varlık: metinler + web + menü/playlist + etkinlik akışı
- Operasyon: minimum checklists + otomasyon

## 5) Notlar / rewrite queue
Eğer “rewrite queue” gerekiyorsa: `pena/rewrite-queue.md`
Aksi halde aktif işler sadece `docs/NOW.md` üzerinden yürütülür.
