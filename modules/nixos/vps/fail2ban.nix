{ config, pkgs, ... }:

{
  services.fail2ban = {
    enable = true;
    jails = {
      sshd = {
        enabled = true;
        settings = {
          port = "ssh";
          filter = "sshd";
          logpath = "/var/log/auth.log";
          maxretry = "5";
        };
      };
    };
  };
}

