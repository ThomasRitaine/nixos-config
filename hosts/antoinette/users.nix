{ config, ... }:

{
  age.secrets = {
    thomas-password.file = ../../secrets/servers/antoinette/thomas-password.age;
    root-password.file = ../../secrets/servers/antoinette/root-password.age;
  };

  users.mutableUsers = false;
  users.users = {
    root = {
      isNormalUser = false;
      hashedPasswordFile = config.age.secrets.root-password.path;
    };
    thomas = {
      isNormalUser = true;
      description = "Thomas";
      home = "/home/thomas";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      hashedPasswordFile = config.age.secrets.thomas-password.path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFDBWxSC0X5OEFoc+DK8ZmWrDERNQwGzUNG8261IedI Thomas Ritaine"
      ];
    };
  };
}
