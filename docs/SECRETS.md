# Secrets (Canonical)

TL;DR:
- Secret/token/private key/DB dump repoya girmez.
- Repoda sadece şablonlar ve “hangi servis hangi dosyayı bekliyor?” dokümanı bulunur.
- Gerçek secretlar root-owned bir dizinde tutulur (örn. `/etc/nixos/secrets/`) ve `chmod 600` yapılır.

# Secrets Policy

Bu repo “dijital miras” olsun diye her şeyi taşır; ancak **secret içermez**.

## Secret nedir?

Repo dışına çıkması gereken her şey:
- API token’lar (Cloudflare, GitHub, vb.)
- Private key / SSH key / cert
- Parola içeren `.env` dosyaları
- DB dump / backup dosyaları
- Kişisel veriler / müşteri verileri

## Bu repoda nasıl temsil ediyoruz?

- Repo içinde: **şablon / örnek / referans**
- Repo dışında: **gerçek secret dosyaları**

Örnek yaklaşım:
- Gerçek secretlar: `/etc/nixos/secrets/` (veya `/srv/secrets/`)
- Repoda sadece: “hangi servis hangi dosyayı bekliyor?” dokümantasyonu

## Pratik kural

- Bir dosyada “token=”, “password=”, “secret=”, “BEGIN PRIVATE KEY” görüyorsan:
  - Repoya girmez.
  - Secret klasörüne taşınır.
  - Repoya bir `.example` / `.template` konur.

## Önerilen klasör düzeni (repo DIŞI)

- `/etc/nixos/secrets/`
  - `cloudflare.env`
  - `github.env`
  - `erpnext.env` (gerekirse)

Bu dosyalar root-owned ve kısıtlı izinlerle tutulur:
- `chmod 600`
- `chown root:root`
