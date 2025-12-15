# Pena + ERP Documentation

Bu dizin, Pena (Karaköy) vizyonu ve ERPNext (URY) dijital altyapısının tek “source of truth” dokümantasyonudur.

## Okuma sırası
1) `00-START/README.md` – Neden var, ne inşa ediyoruz?
2) `HOUSE/` – Manifesto, House Rules, dil ve estetik
3) `ARCH/` – Dijital mimari (NixOS, homelab, repo, servisler)
4) `ERP/` – ERPNext tasarım kararları, modüller, süreçler
5) `OPS/` – Operasyon: deploy, backup, restore, incident yaklaşımı
6) `ROADMAP/` – Şimdi / sonra / bir gün
7) `NOTES/` – Ham notlar (yeniden yazılacak)

## İlkeler
- “Dokümanlar yaşayan şeylerdir”: Kısa, güncel ve referans verilebilir olmalı.
- “Ne yaptık?” değil, “Nasıl yapılır?” odaklı runbook’lar tercih edilir.
- Secret yok: `docs/SECRETS.md`.

İlgili runbook:
- ERP stack operasyonu: `stacks/erpnext/README.md`
