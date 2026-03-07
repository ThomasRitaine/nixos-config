{
  nix.settings.trusted-users = [ "thomas" ];

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;

    extraRules = [
      {
        users = [ "thomas" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/nix-store *";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-env *";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/systemd-run *";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/nix/store/*/bin/switch-to-configuration *";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
