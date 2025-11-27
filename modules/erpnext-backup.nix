{ config, lib, pkgs, ... }:

let
  mkBackupService =
    lane: {
      description = "ERPNext backup (${lane})";

      # PATH'e docker, gzip, coreutils ekle
      path = [
        pkgs.docker
        pkgs.gzip
        pkgs.coreutils
      ];

      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };

      script = ''
        set -eu

        CONFIG="/etc/erpnext-backup.conf"

        if [ ! -f "$CONFIG" ]; then
          echo "[erpnext-backup] Missing $CONFIG" >&2
          exit 1
        fi

        # DB_CONTAINER, DB_NAME, BACKUP_DIR, DB_USER, DB_PASSWORD buradan geliyor
        . "$CONFIG"

        if [ -z "$DB_CONTAINER" ] || [ -z "$DB_NAME" ] || [ -z "$BACKUP_DIR" ]; then
          echo "[erpnext-backup] DB_CONTAINER / DB_NAME / BACKUP_DIR not set in $CONFIG" >&2
          exit 1
        fi

        # Defaults
        if [ -z "$DB_USER" ]; then
          DB_USER="root"
        fi

        PASS_ARG=""
        if [ -n "$DB_PASSWORD" ]; then
          PASS_ARG="--password=$DB_PASSWORD"
        fi

        mkdir -p "$BACKUP_DIR"

        LANE="${lane}"
        TS=$(date +%Y%m%d-%H%M%S)
        OUT="$BACKUP_DIR/erpnext-$LANE.sql.gz"
        TMP="$OUT.tmp"

        echo "[erpnext-backup] $(date '+%F %T') lane=$LANE: starting backup..."

        docker exec -i "$DB_CONTAINER" mysqldump \
          --user="$DB_USER" \
          $PASS_ARG \
          "$DB_NAME" \
          | gzip > "$TMP"

        mv "$TMP" "$OUT"

        echo "[erpnext-backup] $(date '+%F %T') lane=$LANE: backup complete: $OUT"
      '';
    };
in
{
  ################################
  # Services
  ################################
  systemd.services.erpnext-backup-daily = mkBackupService "daily";
  systemd.services.erpnext-backup-weekly = mkBackupService "weekly";
  systemd.services.erpnext-backup-monthly = mkBackupService "monthly";
  systemd.services.erpnext-backup-quarterly = mkBackupService "quarterly";

  ################################
  # Timers
  ################################
  systemd.timers.erpnext-backup-daily = {
    description = "ERPNext backup daily timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  systemd.timers.erpnext-backup-weekly = {
    description = "ERPNext backup weekly timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun *-*-* 03:00:00";
      Persistent = true;
    };
  };

  systemd.timers.erpnext-backup-monthly = {
    description = "ERPNext backup monthly timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-01 04:00:00";
      Persistent = true;
    };
  };

  systemd.timers.erpnext-backup-quarterly = {
    description = "ERPNext backup quarterly timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-01,04,07,10-01 05:00:00";
      Persistent = true;
    };
  };
}
