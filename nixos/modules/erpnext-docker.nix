{ config, lib, pkgs, ... }:

{
  systemd.services.erpnext-docker = {
    description = "ERPNext Docker stack (frappe_docker pwd.yml)";
    after = [ "network-online.target" "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/srv/erpnext";

      # docker CLI'nin tam path'ini kullanıyoruz ki emin olalım
      ExecStart = [
        "/run/current-system/sw/bin/docker compose -f pwd.yml up -d"
      ];
      ExecStop = [
        "/run/current-system/sw/bin/docker compose -f pwd.yml down"
      ];
    };
  };
}
