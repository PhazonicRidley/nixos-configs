# disko config for the VPS: 100 GiB /dev/sda (QEMU), GPT, hybrid BIOS + UEFI boot
{ lib, ... }:
{
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          # BIOS boot partition for GRUB (replaces sda14, 4M)
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          # EFI System Partition (replaces sda15, 106M, and sda13 /boot)
          esp = {
            name = "ESP";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          # Root filesystem takes the rest of the disk (replaces sda1, ~98.9G)
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "defaults" ];
            };
          };
        };
      };
    };
  };
}
