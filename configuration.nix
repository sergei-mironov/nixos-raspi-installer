{ config, pkgs, lib, secrets, ... }:
{
  # Do not compress the image
  sdImage.compressImage = false;
  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # !!! Set to specific linux kernel version
  boot.kernelPackages = pkgs.linuxPackages;

  # # Disable ZFS on kernel 6
  # boot.supportedFilesystems = lib.mkForce [
  #   "vfat"
  #   "xfs"
  #   "cifs"
  #   "ntfs"
  # ];

  boot.kernelParams = lib.mkForce [
    "cma=256M"
    "console=tty0"
    "console=ttyS1,115200n8"
  ];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    # Prior to 19.09, the boot partition was hosted on the smaller first partition
    # Starting with 19.09, the /boot folder is on the main bigger partition.
    # The following is to be used only with older images.
    /*
      "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
      };
    */
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  zramSwap = {
    enable = true;
    memoryPercent = 30;
    algorithm = "zstd";
  };

  environment.systemPackages = with pkgs; [
    vim
    curl
    wget
    bind
    iptables
    gitFull
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Re-Enable auto-start of wpa_supplicant
  systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 60 [ "multi-user.target" ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  hardware = {
    enableRedistributableFirmware = true;
    firmware = [ pkgs.wireless-regdb ];
  };

  networking = {
    hostName = "raspi4";
    firewall.enable = false;
    wireless = {
      enable = true;
      networks = secrets.networks;
    };
  };

  system.stateVersion = "24.05";
}
