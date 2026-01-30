let
  # --- Deployment key ---
  thomas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFDBWxSC0X5OEFoc+DK8ZmWrDERNQwGzUNG8261IedI Thomas Ritaine";
  age = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICkbqjNa9DfiJbkIpBFCEpIAho54pU6SrA4x4YQxEnWT";

  # --- Groups ---
  admins = [
    thomas
    age
  ];

  # --- Hosts keys ---
  vps_8karm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+uyYaOKnjmKqZ8Mi+eYgfEsLi7wYnxcHi7z6xb4b1z";
  orarm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+Y7b+rqdmp99Y6IBnrfs5I9WvAuGbz3pfrsg7A0J+A";
  pharaoh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJL6MIeBTmTbS6rUFPQ0T1QW0E/TFzD9/g3k+fAXCneO";
  koola = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcDHGT++TE1b2puzdsFZ3COtca/NudBDzkAM9mqjfPx";
  despo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEnqFnRsBHrLBxNz5ijujo58S4BpXkConso1m8nssOsp";
in
{
  # --- vps-8karm ---
  "servers/vps-8karm/thomas-password.age".publicKeys = admins ++ [ vps_8karm ];
  "servers/vps-8karm/root-password.age".publicKeys = admins ++ [ vps_8karm ];
  "servers/vps-8karm/app-manager-password.age".publicKeys = admins ++ [ vps_8karm ];
  "servers/vps-8karm/applications-backup-env.age".publicKeys = admins ++ [ vps_8karm ];

  # --- orarm ---
  "servers/orarm/thomas-password.age".publicKeys = admins ++ [ orarm ];
  "servers/orarm/root-password.age".publicKeys = admins ++ [ orarm ];
  "servers/orarm/app-manager-password.age".publicKeys = admins ++ [ orarm ];

  # --- pharaoh ---
  "servers/pharaoh/thomas-password.age".publicKeys = admins ++ [ pharaoh ];
  "servers/pharaoh/root-password.age".publicKeys = admins ++ [ pharaoh ];
  "servers/pharaoh/app-manager-password.age".publicKeys = admins ++ [ pharaoh ];

  # --- koola ---
  "servers/koola/thomas-password.age".publicKeys = admins ++ [ koola ];
  "servers/koola/root-password.age".publicKeys = admins ++ [ koola ];
  "servers/koola/app-manager-password.age".publicKeys = admins ++ [ koola ];

  # --- despo ---
  "servers/despo/thomas-password.age".publicKeys = admins ++ [ despo ];
  "servers/despo/root-password.age".publicKeys = admins ++ [ despo ];
  "servers/despo/app-manager-password.age".publicKeys = admins ++ [ despo ];
}
