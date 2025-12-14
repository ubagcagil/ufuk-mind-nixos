# NOW

> Single source of truth for "where we are" and "what's next".

## Current focus

1) Repo renovation (docs + structure)
2) ERPNext stack: stable + reproducible
3) Backups: verified + rotating lanes (daily/weekly/monthly/quarterly)
4) Keep the machine “zen”: no failed units, reasonable disk usage, minimal drift

## Next actions (short)

- [ ] Finalize docs skeleton (index, life-tree, now, runbooks)
- [ ] Commit current changes (no secrets)
- [ ] Normalize ERPNext runbook: compose, images, assets fix, volumes
- [ ] Capture backup mechanism + validation commands
- [ ] Add minimal “how to bootstrap on a new machine” notes

## Notes

- `sys-update` is the default NixOS apply command (flake-based).
- Runtime state (docker volumes, /srv data) is **not** in git; we document it and keep it reproducible.
