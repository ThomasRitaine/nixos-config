{
  fileSystems."/var/lib/frigate/recordings" = {
    device = "/dev/disk/by-uuid/75bb1581-d10d-4ba9-9b3b-d92e2569e793";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
    ];
  };
}
