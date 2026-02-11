let
  domain = "beszel.thomas.ritaine.com";
in
{
  services.beszel.hub = {
    enable = true;
    host = "0.0.0.0";
    port = 8090;
    environment = {
      APP_URL = "https://${domain}";
    };
  };

  environment.etc."traefik/dynamic/beszel.yml" = {
    text = ''
      http:
        routers:
          beszel:
            rule: "Host(`${domain}`)"
            entryPoints:
              - "websecure"
            service: "beszel"

        services:
          beszel:
            loadBalancer:
              servers:
                - url: "http://127.0.0.1:8090"
    '';
  };
}
