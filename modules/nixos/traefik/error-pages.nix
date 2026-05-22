{ pkgs, lib, ... }:

let
  error-pages = pkgs.buildGoModule rec {
    pname = "error-pages";
    version = "4.2.0";

    src = pkgs.fetchFromGitHub {
      owner = "tarampampam";
      repo = "error-pages";
      rev = "v${version}";
      hash = "sha256-CLl8SnZTT6siYJWCr+Bd+5vPqXeDi+qYW905GjFhDEY=";
    };

    vendorHash = null;
    subPackages = [ "cmd/error-pages" ];

    meta = with lib; {
      description = "Tiny HTTP server serving pretty, themeable error pages — drop-in for Traefik";
      homepage = "https://github.com/tarampampam/error-pages";
      license = licenses.mit;
      mainProgram = "error-pages";
      platforms = platforms.linux;
    };
  };
in
{
  systemd.services.error-pages = {
    description = "error-pages HTTP server for Traefik error handling";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    environment = {
      TEMPLATE_NAME = "orient";
      LOG_LEVEL = "warn";
      LISTEN_ADDR = "127.0.0.1";
      LISTEN_PORT = "8085";
      PORT = "8085";
    };

    serviceConfig = {
      ExecStart = "${error-pages}/bin/error-pages";
      Restart = "on-failure";
      RestartSec = "5s";
      DynamicUser = true;

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
    };
  };
}
