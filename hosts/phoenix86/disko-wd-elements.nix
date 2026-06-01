{ inputs, ... }:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk.wdelements = {
      type = "disk";
      device = "/dev/disk/by-id/usb-WD_Elements_25A2_57585831453838304B365853-0:0";
      content = {
        type = "gpt";
        partitions = {
          data = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/mnt/wd-elements";
              mountOptions = [
                "defaults"
                "noatime"
                "nofail"
              ];
            };
          };
        };
      };
    };
  };
}
