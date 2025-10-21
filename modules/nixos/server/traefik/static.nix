{ email, dynamicConfigDir }:

{
  api = {
    dashboard = true;
    insecure = true;
  };

  log = {
    level = "ERROR";
    format = "common";
  };

  accessLog = { format = "common"; };

  entryPoints = {
    web = {
      address = ":80";
      http = {
        redirections = {
          entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };
      };
    };

    websecure = {
      address = ":443";
      asDefault = true;
      http = {
        middlewares = [ "nofloc@file" "secureHeaders@file" ];
        tls = { certResolver = "letsencrypt"; };
      };
    };
  };

  pilot = { dashboard = false; };

  providers = {
    docker = {
      endpoint = "unix:///var/run/docker.sock";
      exposedByDefault = false;
      network = "traefik";
    };

    file = {
      directory = dynamicConfigDir;
      watch = true;
    };
  };

  certificatesResolvers = {
    letsencrypt = {
      acme = {
        email = email;
        storage = "/var/lib/traefik/certificates/acme.json";
        tlsChallenge = true;
      };
    };
  };

  experimental = {
    plugins = {
      checkheadersplugin = {
        moduleName = "github.com/dkijkuit/checkheadersplugin";
        version = "v0.3.1";
      };
    };
  };
}
