# ADR-0001: Monorepo + kontrat yaklaşımı

## Status
Accepted

## Context
Tek repo içinde (NixOS + stacks + Pena + öğrenme) çok alan var. Dağılmayı engellemek için net sınırlar gerekiyor.

## Decision
- `docs/REPO-CONTRACT.md` “tek kaynak gerçek” kabul edildi.
- Secret ve runtime state repoya alınmayacak.
- Büyük kararlar ADR olarak kaydedilecek.

## Consequences
- Uzun vadede sürdürülebilirlik ve LLM bağlam aktarımı kolaylaşır.
- Bazı şeyler “neden repoda değil?” sorusunu doğurur; cevap kontratta.
