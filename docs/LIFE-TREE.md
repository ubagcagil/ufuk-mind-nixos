# LIFE TREE

Bu repo: **kaynak gerçek** (source of truth).  
Makinenin çalışır hali: **runtime state** (docker volumes, /srv, loglar) — repoya girmez, sadece dokümante edilir.

## ASCII Map (Repo → Runtime)


/etc/nixos (GIT: source of truth)
├─ flake.nix
├─ nixos/
│ ├─ hosts/
│ │ ├─ ufuk-desktop/default.nix
│ │ └─ ufuk-laptop/default.nix
│ └─ modules/
│ ├─ core/
│ │ └─ sys-update.nix (sys-update komutu + helper’lar)
│ └─ ... (diğer modüller)
├─ stacks/
│ └─ erpnext/
│ ├─ pwd.yml (docker compose)
│ ├─ images/custom/Containerfile
│ └─ scripts/backup.sh (backup orchestration)
└─ docs/
├─ INDEX.md
├─ NOW.md
└─ LIFE-TREE.md

RUNTIME (GIT DIŞI: state)
├─ /srv/erpnext (compose working dir)
├─ /srv/erpnext-backups (backup outputs: sql.gz + files tar + config json)
└─ /var/lib/docker/volumes (sites, db-data, redis, logs, ...)


## What lives where?

### In git (should be reproducible)
- NixOS configuration (hosts, modules)
- ERPNext stack definitions (compose, Containerfile, scripts)
- Docs / runbooks / decisions

### Not in git (document only)
- Secrets (tokens, keys, certs)
- Live databases, docker volumes, site files
- Backups (outputs)

## Safety rules (never commit)
- `*.key`, `*.pem`, `*.pfx`, `*.p12`, `.env*`, `secrets/`, anything matching `*secret*`, `*token*`
- Runtime: `srv/`, `var/`, `run/`, `**/logs/`, `**/backups/`, `*.sql*`, `*.tgz`, `*.tar*`

(Repodaki `.gitignore` bunu enforce eder; gerektiğinde genişletiriz.)


# Life-Tree

Aşağıdaki şema bu repo’nun “hayat ağacı” organizasyonunu görsel olarak özetler.

```text
life-tree (/etc/nixos)
├── docs/
│   ├── INDEX.md
│   ├── NOW.md
│   ├── SECRETS.md
│   ├── LIFE-TREE.md
│   └── PENA/
│       ├── README.md
│       ├── 00-START/
│       ├── HOUSE/
│       ├── ARCH/
│       ├── ERP/
│       ├── OPS/
│       ├── ROADMAP/
│       └── NOTES/
├── nixos/
│   ├── flake.nix / flake.lock
│   ├── hosts/
│   │   ├── ufuk-desktop/
│   │   └── ufuk-laptop/
│   └── modules/
│       └── core/
│           ├── sys-update.nix
│           └── ...
├── stacks/
│   └── erpnext/
│       ├── README.md
│       ├── scripts/
│       │   └── backup.sh
│       └── ...
└── README.md

Not: Bu şema “yaklaşık” bir haritadır; zamanla repo büyüdükçe güncellenir.
