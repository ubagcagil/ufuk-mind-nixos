{ config, lib, pkgs, ... }:

let
  backupScript = pkgs.writeShellScript "erpnext-backup" (builtins.readFile ../../stacks/erpnext/scripts/backup.sh);

  mkBackupService = lane: {
    description = "ERPNext backup (${lane})";

    wants = [ "erpnext-docker.service" ];
    after = [ "docker.service" "erpnext-docker.service" ];
    requires = [ "docker.service" ];

    path = [
      pkgs.docker
      pkgs.coreutils
      pkgs.gnutar
      pkgs.gzip
    ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Environment = [
        "STACK_DIR=/srv/erpnext"
        "COMPOSE_FILE=pwd.yml"
        "SITE=frontend"
        "BACKEND_SERVICE=backend"
        "OUT_DIR=/srv/erpnext-backups"
      ];
    };

script = ''
      set -euo pipefail
      ${backupScript} ${lane}
    '';
  };
in
{
  systemd.tmpfiles.rules = [
    "d /srv/erpnext-backups 0750 root root - -"
  ];

  systemd.services.erpnext-backup-daily     = mkBackupService "daily";
  systemd.services.erpnext-backup-weekly    = mkBackupService "weekly";
  systemd.services.erpnext-backup-monthly   = mkBackupService "monthly";
  systemd.services.erpnext-backup-quarterly = mkBackupService "quarterly";

systemd.timers.erpnext-backup-daily = {
    wantedBy = [ "timers.target" ];
    timerConfig = { OnCalendar = "daily"; Persistent = true; };
  };

  systemd.timers.erpnext-backup-weekly = {
    wantedBy = [ "timers.target" ];
    timerConfig = { OnCalendar = "Sun *-*-* 03:00:00"; Persistent = true; };
  };

  systemd.timers.erpnext-backup-monthly = {
    wantedBy = [ "timers.target" ];
    timerConfig = { OnCalendar = "*-*-01 04:00:00"; Persistent = true; };
  };

  systemd.timers.erpnext-backup-quarterly = {
    wantedBy = [ "timers.target" ];
    timerConfig = { OnCalendar = "*-01,04,07,10-01 05:00:00"; Persistent = true; };
  };
}
