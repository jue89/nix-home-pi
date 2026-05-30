{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs = { self, nixpkgs, nixos-raspberrypi }: let
    hosts = {
      Bedroom = {
        extraModules = [ nixos-raspberrypi.nixosModules.raspberry-pi-3.base ];
      };
      Kitchen = {
        extraModules = [ nixos-raspberrypi.nixosModules.raspberry-pi-3.base ];
      };
    };
  in {
    nixosConfigurations = builtins.mapAttrs (name: { extraModules }: nixos-raspberrypi.lib.nixosSystem {
      specialArgs = {
        hostName = name;
      };
      modules = [
        nixos-raspberrypi.nixosModules.trusted-nix-caches
        nixos-raspberrypi.nixosModules.nixpkgs-rpi
        nixos-raspberrypi.nixosModules.sd-image
        ./common.nix
      ] ++ extraModules;
    }) hosts;

    images = builtins.mapAttrs (name: value: self.nixosConfigurations.${name}.config.system.build.sdImage) hosts;
  };
}
