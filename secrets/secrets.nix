let
  # --- Deployment key ---
  thomas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFDBWxSC0X5OEFoc+DK8ZmWrDERNQwGzUNG8261IedI Thomas Ritaine";
  age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkbqjNa9DfiJbkIpBFCEpIAho54pU6SrA4x4YQxEnWT";

  # --- Hosts keys ---
  vps_8karm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+uyYaOKnjmKqZ8Mi+eYgfEsLi7wYnxcHi7z6xb4b1z";
  orarm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+Y7b+rqdmp99Y6IBnrfs5I9WvAuGbz3pfrsg7A0J+A";
  pharaoh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJL6MIeBTmTbS6rUFPQ0T1QW0E/TFzD9/g3k+fAXCneO";
  koola = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcDHGT++TE1b2puzdsFZ3COtca/NudBDzkAM9mqjfPx";
  despo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnqFnRsBHrLBxNz5ijujo58S4BpXkConso1m8nssOsp";
  grisou = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO8gn/7FRr6/hDXWhAKUJlcvlwlfOjduYkOmps8qYrE2";
  sushi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMkwDkkMJMNYo/10OpEAydmm9eaqNCo7dmHASLpPtcxD";
  mc-estou = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBOni/6GK4fV8rGqCVLcF21x4IT6afHNtXgFzPOYI5sS";
  agouz = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL75fRY3zU/n2jHC83PDZw2V3UMr70BZZmsnsg1DPqxR";
  picsou = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHwk4r75LYPuFd50nxijOyrwuN6gDjfQqHhrfig89Nq8";

  # --- Groups ---
  admins = [
    thomas
    age
  ];

  servers = [
    vps_8karm
    orarm
    pharaoh
    koola
    despo
    grisou
    sushi
    mc-estou
    agouz
    picsou
  ];
in
{
  # --- vps-8karm ---
  "servers/vps-8karm/thomas-password.age".publicKeys = admins ++ [ vps_8karm ];
  "servers/vps-8karm/root-password.age".publicKeys = admins ++ [ vps_8karm ];
  "servers/vps-8karm/app-manager-password.age".publicKeys = admins ++ [ vps_8karm ];
  "servers/vps-8karm/applications-backup-env.age".publicKeys = admins ++ [ vps_8karm ];
  "servers/vps-8karm/restic-password.age".publicKeys = admins ++ [ vps_8karm ];

  # --- orarm ---
  "servers/orarm/thomas-password.age".publicKeys = admins ++ [ orarm ];
  "servers/orarm/root-password.age".publicKeys = admins ++ [ orarm ];
  "servers/orarm/restic-password.age".publicKeys = admins ++ [ orarm ];

  # --- pharaoh ---
  "servers/pharaoh/thomas-password.age".publicKeys = admins ++ [ pharaoh ];
  "servers/pharaoh/root-password.age".publicKeys = admins ++ [ pharaoh ];
  "servers/pharaoh/restic-password.age".publicKeys = admins ++ [ pharaoh ];

  # --- koola ---
  "servers/koola/thomas-password.age".publicKeys = admins ++ [ koola ];
  "servers/koola/root-password.age".publicKeys = admins ++ [ koola ];
  "servers/koola/restic-password.age".publicKeys = admins ++ [ koola ];

  # --- despo ---
  "servers/despo/thomas-password.age".publicKeys = admins ++ [ despo ];
  "servers/despo/root-password.age".publicKeys = admins ++ [ despo ];
  "servers/despo/restic-password.age".publicKeys = admins ++ [ despo ];

  # --- grisou ---
  "servers/grisou/thomas-password.age".publicKeys = admins ++ [ grisou ];
  "servers/grisou/root-password.age".publicKeys = admins ++ [ grisou ];
  "servers/grisou/restic-password.age".publicKeys = admins ++ [ grisou ];

  # --- sushi ---
  "servers/sushi/thomas-password.age".publicKeys = admins ++ [ sushi ];
  "servers/sushi/root-password.age".publicKeys = admins ++ [ sushi ];
  "servers/sushi/restic-password.age".publicKeys = admins ++ [ sushi ];

  # --- mc-estou ---
  "servers/mc-estou/thomas-password.age".publicKeys = admins ++ [ mc-estou ];
  "servers/mc-estou/root-password.age".publicKeys = admins ++ [ mc-estou ];
  "servers/mc-estou/restic-password.age".publicKeys = admins ++ [ mc-estou ];

  # --- agouz ---
  "servers/agouz/thomas-password.age".publicKeys = admins ++ [ agouz ];
  "servers/agouz/root-password.age".publicKeys = admins ++ [ agouz ];
  "servers/agouz/restic-password.age".publicKeys = admins ++ [ agouz ];

  # --- picsou ---
  "servers/picsou/thomas-password.age".publicKeys = admins ++ [ picsou ];
  "servers/picsou/root-password.age".publicKeys = admins ++ [ picsou ];
  "servers/picsou/restic-password.age".publicKeys = admins ++ [ picsou ];

  # --- Global ---
  "servers/foldingathome-token.age".publicKeys = admins ++ servers;
  "servers/tailscale-token.age".publicKeys = admins ++ servers;
  "servers/beszel-key-and-token.age".publicKeys = admins ++ servers;
  "servers/restic-s3-creds.age".publicKeys = admins ++ servers;
  "servers/restic-s3-endpoint.age".publicKeys = admins ++ servers;
  "servers/garage-rpc-secret.age".publicKeys = admins ++ servers;
  "servers/garage-bootstrap-peers.age".publicKeys = admins ++ servers;
}
