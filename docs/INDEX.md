# Docs Index

Bu klasör, repo ve sistemin çalışma biçimi için tek referans noktasıdır.

## Start here

- **NOW**: şu an ne yapıyoruz, sıradaki adımlar  
  → `docs/NOW.md`
- **LIFE TREE**: repo → runtime ayrımı + ASCII harita  
  → `docs/LIFE-TREE.md`

## Runbooks (operasyon)

- ERPNext stack (compose, build, assets, troubleshooting)  
  → `stacks/erpnext/`
- Backups (rotating lanes, validation, restore)  
  → `stacks/erpnext/scripts/backup.sh` + ilgili NixOS units

## Principles

- Secrets ve runtime state **repoya girmez** (dokümante edilir).
- Reproducibility: “yeni bir makinede aynı sonuç” hedeflenir.

- Stack Runbook: `stacks/erpnext/README.md`

- Pena + ERP Docs: `docs/PENA/README.md`
