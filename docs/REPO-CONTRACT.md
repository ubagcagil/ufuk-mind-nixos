# Repo Contract (v1)

Bu repo, UfukOS homelab (NixOS) + servis stack’leri + Pena (kafe) dijital altyapısı + öğrenme/AR-GE notlarını tek yerden yönetmek içindir.

## Altın Kurallar
1) Secret/token/private key/DB dump repoya girmez.
2) Runtime state repoya girmez (container volume, DB data, backup dosyaları, loglar).
3) Repoya giren her şey: yeniden üretilebilir bilgi (config, şablon, runbook, ADR).
4) Her değişiklik küçük commit’lerle yapılır.

## Klasör Kontratları
- `nixos/`:
  - Amaç: “bu makine nasıl çalışıyor?” sorusunun cevabı.
  - İçerik: flake, host entrypoint’leri, modüller.
- `stacks/`:
  - Amaç: runtime servislerin *tanımı* + operasyon bilgisi.
  - İçerik: compose/manifest + runbook + script + şablon.
  - Not: gerçek data/backup dosyaları `stacks/**/state/` gibi gitignored alanlarda tutulur.
- `docs/`:
  - INDEX: portal.
  - NOW: aktif işler.
  - ADR: mimari karar kayıtları.
  - runbooks/: “komut komut nasıl yapılır?”
  - dr/: felaket kurtarma senaryoları.
- `pena/`:
  - Amaç: kafenin kültür/metin/operasyonel dokümanları.
  - Not: müşteri verisi, gerçek muhasebe çıktısı, DB dump repoya girmez.

## İsimlendirme
- Hostname’ler: `ufuk-desktop`, `ufuk-laptop` vb.
- Runbook dosyaları: fiil odaklı (`sys-update`, `restore-host`, `backup-rotate`).
- ADR: `docs/adr/NNNN-kisa-baslik.md`

## “Yeni Ben / LLM” için okuma sırası
1) `docs/INDEX.md`
2) `docs/NOW.md`
3) `docs/LIFE-TREE.md`
4) ilgili `runbooks/` ve `stacks/.../` runbook’ları
