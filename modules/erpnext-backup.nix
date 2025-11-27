{ config, pkgs, ... }:

let
  backupRoot = "/var/backups/erpnext";

  erpnextBackupScript = pkgs.writeShellScriptBin "erpnext-db-backup" ''
    #!/usr/bin/env bash
    set -euo pipefail

    CONFIG="/etc/erpnext-backup.conf"

    if [ ! -f "$CONFIG" ]; then
      echo "[erpnext-backup] Missing $CONFIG, aborting." >&2
      exit 1
    fi

    # shellcheck disable=SC1091
    . "$CONFIG"

    if [ -z "${DB_CONTAINER:-}" ] || [ -z "${DB_NAME:-}" ]; then
      echo "[erpnext-backup] DB_CONTAINER or DB_NAME not set in $CONFIG" >&2
      exit 1
    fi

    BACKUP_ROOT="${backupRoot}"

    mkdir -p "$BACKUP_ROOT"/{daily,weekly,monthly,quarterly}

    dump_into () {
      local target="$1"
      echo "[erpnext-backup] Writing $target"

      docker exec -e DB_NAME="$DB_NAME" "$DB_CONTAINER" sh -c '
        PASS="${MARIADB_ROOT_PASSWORD:-$MYSQL_ROOT_PASSWORD}"
        if [ -z "$PASS" ]; then
          echo "No MARIADB_ROOT_PASSWORD or MYSQL_ROOT_PASSWORD set in container" >&2
          exit 1
        fi
        mysqldump -u root -p"$PASS" "$DB_NAME"
      ' | gzip -c > "$target"
    }

    # her gün: daily (aynı dosyanın üstüne yazar)
    dump_into "$BACKUP_ROOT/daily/erpnext-daily.sql.gz"

    dow="$(date +%u)"   # 1..7 (Mon..Sun)
    dom="$(date +%d)"   # 01..31
    mon="$(date +%m)"   # 01..12

    # haftalık: pazar günleri
    if [ "$dow" = "7" ]; then
      dump_into "$BACKUP_ROOT/weekly/erpnext-weekly.sql.gz"
    fi

    # aylık: her ayın 1'i
    if [ "$dom" = "01" ]; then
      dump_into "$BACKUP_ROOT/monthly/erpnext-monthly.sql.gz"
    fi

    # çeyrek: 01.01, 01.04, 01.07, 01.10
    if [ "$dom" = "01" ] && \
       { [ "$mon" = "01" ] || [ "$mon" = "04" ] || [ "$mon" = "07" ] || [ "$mon" = "10" ]; }
    then
      dump_into "$BACKUP_ROOT/quarterly/erpnext-quarterly.sql.gz"
    fi
  '';
in
{
  #### Backup klasörleri
  systemd.tmpfiles.rules = [
    "d ${backupRoot} 0700 root root -"
    "d ${backupRoot}/daily 0700 root root -"
    "d ${backupRoot}/weekly 0700 root root -"
    "d ${backupRoot}/monthly 0700 root root -"
    "d ${backupRoot}/quarterly 0700 root root -"
  ];

  #### Basit config dosyası (şifresiz; sadece isimler)
  environment.etc."erpnext-backup.conf".text = ''
    # ERPNext DB backup config
    # Docker içindeki MariaDB/MySQL container adını yaz:
    # Örn: DB_CONTAINER="pena-mariadb-1"
    DB_CONTAINER="CHANGE_ME_DB_CONTAINER"

    # Yedeklenecek veritabanı adı:
    # Örn: DB_NAME="erpnext" veya "site1.local" vs.
    DB_NAME="CHANGE_ME_DB_NAME"
  '';

  #### Script'i sisteme ekle
  environment.systemPackages = [
    erpnextBackupScript
  ];

  #### systemd service + timer
  systemd.services.erpnext-backup = {
    description = "ERPNext MariaDB backup (daily/weekly/monthly/quarterly)";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${erpnextBackupScript}/bin/erpnext-db-backup";
      User = "root";
    };
  };

  systemd.timers.erpnext-backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
