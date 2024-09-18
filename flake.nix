{
  inputs = {
    nixpkgs = {
      # Author's favorite nixpkgs
      url = "github:grwlf/nixpkgs/local17";
    };

    secrets = {
      # One can use `secrets.nix.template` as a template.
      #
      # $ cp ./secrets.nix.template ./_secrets.nix
      # $ edit ./_secrets.nix
      # $ nix registry add nixos-raspi-installer-secrets ./_secrets.nix
      url = "flake:nixos-raspi-installer-secrets";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, secrets }: let
    inherit (nixpkgs.lib) nixosSystem;
    raspi-nixos = self.outputs.nixosConfigurations.raspi;
    system-host = "x86_64-linux";
    system-target = "aarch64-linux";
    pkgs = import nixpkgs { system = system-host; };
  in rec {

    packages = {
      x86_64-linux = rec {

        sdimage = raspi-nixos.config.system.build.sdImage;

        uboot3 = raspi-nixos.pkgs.ubootRaspberryPi3_64bit;

        qemu-raspi3 = pkgs.writeScript "qemu-raspi3" ''
          #!${pkgs.runtimeShell}

          set -e -x
          IMG=_aarch64-qemu.img
          cp -f ${sdimage}/*/*img "$IMG"
          chmod 0640 "$IMG"
          ${pkgs.qemu}/bin/qemu-img resize -f raw "$IMG" 4G

          ${pkgs.qemu}/bin/qemu-system-aarch64 \
            -machine raspi3b \
            -kernel "${uboot3}/u-boot.bin" \
            -drive file="$IMG",format=raw \
            -device usb-net,netdev=net0 \
            -netdev user,id=net0,hostfwd=tcp::22422-:22 \
            -serial null \
            -serial mon:stdio
        '';
      };
    };

    nixosConfigurations = {
      raspi = nixosSystem {
        system = system-target;
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
          ./configuration.nix
          {
            _module.args = { secrets = import secrets.outPath; };
          }
        ];
      };
    };
  };
}
