{ lib, ... }:
{
  garageAutoCapacity = "1.3T";
  services.garage.settings.data_dir = lib.mkForce [
    {
      path = "/var/lib/garage/data";
      capacity = "300G";
    }
    {
      path = "/mnt/wd-elements/garage-data";
      capacity = "1T";
    }
  ];

  systemd.tmpfiles.rules = [
    "d /mnt/wd-elements/garage-data 0700 root root -"
  ];
}
