{ config, ... }:
{
  age.secrets."cloudflare-origin-cert" = {
    file = ../../secrets/servers/phoenix86/cloudflare-origin-cert.age;
    owner = "nginx";
    group = "nginx";
  };

  age.secrets."cloudflare-origin-cert-key" = {
    file = ../../secrets/servers/phoenix86/cloudflare-origin-cert-key.age;
    owner = "nginx";
    group = "nginx";
  };

  services.nginx = {
    enable = true;
    virtualHosts."phoenix86-thomas.ritaine.com" = {
      forceSSL = true;
      sslCertificate = config.age.secrets."cloudflare-origin-cert".path;
      sslCertificateKey = config.age.secrets."cloudflare-origin-cert-key".path;
      root = "/var/www/phoenix86";

      locations."/" = {
        tryFiles = "$uri $uri/ =404";
      };

      extraConfig = ''
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_session_timeout 10m;
        ssl_session_cache shared:SSL:10m;
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/www/phoenix86 0755 nginx nginx -"
  ];

  services.restic.backups.daily.paths = [ "/var/www/phoenix86" ];
}
