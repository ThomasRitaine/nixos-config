let
  # --- Deployment keys ---
  thomas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFDBWxSC0X5OEFoc+DK8ZmWrDERNQwGzUNG8261IedI Thomas Ritaine";
  age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkbqjNa9DfiJbkIpBFCEpIAho54pU6SrA4x4YQxEnWT";

  admins = [
    thomas
    age
  ];

  # --- Hosts keys ---
  vps-8karm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+uyYaOKnjmKqZ8Mi+eYgfEsLi7wYnxcHi7z6xb4b1z";
  oracleHosts = {
    orarm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+Y7b+rqdmp99Y6IBnrfs5I9WvAuGbz3pfrsg7A0J+A";
    pharaoh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJL6MIeBTmTbS6rUFPQ0T1QW0E/TFzD9/g3k+fAXCneO";
    koola = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcDHGT++TE1b2puzdsFZ3COtca/NudBDzkAM9mqjfPx";
    despo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnqFnRsBHrLBxNz5ijujo58S4BpXkConso1m8nssOsp";
    grisou = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8gn/7FRr6/hDXWhAKUJlcvlwlfOjduYkOmps8qYrE2";
    sushi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMkwDkkMJMNYo/10OpEAydmm9eaqNCo7dmHASLpPtcxD";
    mc-estou = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOni/6GK4fV8rGqCVLcF21x4IT6afHNtXgFzPOYI5sS";
    agouz = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL75fRY3zU/n2jHC83PDZw2V3UMr70BZZmsnsg1DPqxR";
    picsou = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwk4r75LYPuFd50nxijOyrwuN6gDjfQqHhrfig89Nq8";
    joburg = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB7daP2Mkqejm5YDiQOkY7hjwOA3Db/NDUgIkNFd0CKv";
  };

  servers = [ vps-8karm ] ++ (builtins.attrValues oracleHosts);

  mkOracleSecrets = hostname: key: {
    "servers/${hostname}/thomas-password.age".publicKeys = admins ++ [ key ];
    "servers/${hostname}/root-password.age".publicKeys = admins ++ [ key ];
    "servers/${hostname}/restic-password.age".publicKeys = admins ++ [ key ];
  };

  oracleSecrets = builtins.foldl' (
    acc: hostname: acc // (mkOracleSecrets hostname oracleHosts.${hostname})
  ) { } (builtins.attrNames oracleHosts);

in
{
  # vps-8karm
  "servers/vps-8karm/thomas-password.age".publicKeys = admins ++ [ vps-8karm ];
  "servers/vps-8karm/root-password.age".publicKeys = admins ++ [ vps-8karm ];
  "servers/vps-8karm/app-manager-password.age".publicKeys = admins ++ [ vps-8karm ];
  "servers/vps-8karm/applications-backup-env.age".publicKeys = admins ++ [ vps-8karm ];
  "servers/vps-8karm/restic-password.age".publicKeys = admins ++ [ vps-8karm ];

  # Global
  "servers/foldingathome-token.age".publicKeys = admins ++ servers;
  "servers/tailscale-token.age".publicKeys = admins ++ servers;
  "servers/beszel-key-and-token.age".publicKeys = admins ++ servers;
  "servers/restic-s3-creds.age".publicKeys = admins ++ servers;
  "servers/restic-s3-endpoint.age".publicKeys = admins ++ servers;
  "servers/garage-rpc-secret.age".publicKeys = admins ++ servers;
  "servers/garage-bootstrap-peers.age".publicKeys = admins ++ servers;
  "servers/garage-metrics-token.age".publicKeys = admins ++ servers;
}
// oracleSecrets
