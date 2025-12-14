# UfukOS Homelab (NixOS + Stacks)

Bu repo, `ufuk-desktop` ve `ufuk-laptop` NixOS sistemlerini, homelab operasyonlarını ve servis stack’lerini (örn. ERPNext) **tekrar üretilebilir** şekilde tanımlar.

- Amaç: “bu makine nasıl çalışıyor?” sorusunun tek cevabı bu repo olsun.
- Kural: **secret yok**, sadece referans/şablon var. Runtime state repoya girmez.

## Life Tree (yaşam ağacı)

Detaylı açıklama + daha büyük ASCII harita:
- `docs/LIFE-TREE.md`

Kısa görünüm:

```text
repo:/etc/nixos
├─ nixos/                  NixOS tanımları (flake + host + modules)
│  ├─ hosts/               ufuk-desktop / ufuk-laptop giriş noktaları
│  └─ modules/             tekrar kullanılabilir modüller (core, services, ...)
├─ stacks/                 runtime stack’ler (örn. ERPNext) + runbook + scriptler
├─ docs/                   rehber, index, now, mimari notlar
└─ secrets/                (repoda YOK) sadece dokümantasyon/şablon referansı


Hızlı Başlangıç
Sistem güncelleme (tek komut)

Bu repo flake olduğu için host seçimi hostname üzerinden yapılır:

sys-update


Ne yapar?

Bu makinenin hostname değerine göre doğru hedefi seçer (ufuk-desktop / ufuk-laptop)

nixos-rebuild switch --flake /etc/nixos#<hostname> çalıştırır

Not: “Git tree is dirty” uyarısı, commit edilmemiş değişiklik olduğunda gelir. İstersen önce commit et, sonra sys-update çalıştır.

Geri alma (rollback)
sudo nix-env -p /nix/var/nix/profiles/system --list-generations
sudo nixos-rebuild switch --rollback

Repo Haritası

Docs giriş: docs/INDEX.md

Şu an / sıradaki işler: docs/NOW.md

ERPNext stack (compose, ops, backup, troubleshooting): stacks/erpnext/

Prensipler

Secret / token / private key / DB dump repoya girmez.

“Nasıl yapılır?” bilgisi repoya girer: runbook, şablon, komutlar, mimari kararlar.

Her değişiklik küçük, anlaşılır commit’lerle ilerler.

