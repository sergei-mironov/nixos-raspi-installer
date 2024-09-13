{
  inputs = {
    nixpkgs = {
      # Author's favorite nixpkgs
      url = "github:grwlf/nixpkgs/local17";
    };
  };

  outputs = { self, nixpkgs }: rec {
    packages = {
      x86_64-linux = {
        sdimage = nixosConfigurations.raspi4.config.system.build.sdImage;
      };
    };

    nixosConfigurations = {
      raspi4 = nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix"
          ./configuration.nix
          {
            sdImage.compressImage = false;
          }
        ];
      };
    };
  };
}
