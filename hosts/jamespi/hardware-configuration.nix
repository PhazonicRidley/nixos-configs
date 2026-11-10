# JamesPi hardware: Raspberry Pi 3B+ booting from a single SD card.
# Written by hand (nixos-generate-config can't run here); initrd modules,
# firmware, and the kernel come from nixos-raspberrypi's raspberry-pi-3.base.
#
# Expected SD card layout (MBR; the Pi 3 boot ROM needs FAT first):
#   1. vfat, label FIRMWARE  -> /boot/firmware (config.txt, firmware, u-boot)
#   2. ext4, label NIXOS_SD  -> / (extlinux config and kernels live in /boot)
# Same labels as the nixos-raspberrypi installer image.
{ ... }:

{
  fileSystems."/boot/firmware" = {
    device = "/dev/disk/by-label/FIRMWARE";
    fsType = "vfat";
    # Only needed when the bootloader is updated; automount on access
    options = [
      "noatime"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=1min"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  swapDevices = [ ];
}
