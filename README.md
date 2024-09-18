This Nix project defines a expression for building custom NixOS installation image for Raspberry Pi.

Features:

- Default Linux TTY is set to Raspberry Pi's' serial port.
- Nix flakes are enabled by default
- Secrets (default wifi networks credentials) are read from `_secrets.nix`.


Usage:

1. Better be on a NixOS machine. For Nix-capabale non-NixOS machines, everything should work as
   well, but one might need to figure out how to setup the cross-compilation.
2. For x86 NixOS, enable aarch64 cross-compilation by adding the following lines to your local
   machine's configuration and rebuild.
   ``` nix
   boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
   ```
3. Build the SD-card image by running `nix build '.#sdimage'`
4. Insert SD-card and write the image to it with `dd if=./result/ of=/dev/sdX`. Replace `sdX` with
   the write SD-card device
5. Insert the SD-card to a Raspberry Pi, boot it and proceed with the regular NixOS configuration.
