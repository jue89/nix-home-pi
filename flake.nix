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
    rpi3Config = {
      system = "aarch64-linux";
      crossSystem = {
        config = "aarch64-unknown-linux-gnu";
        gcc.arch = "armv8-a";
      };
      modules = [ nixos-raspberrypi.nixosModules.raspberry-pi-3.base ];
    };

    rpi5Config = {
      system = "aarch64-linux";
      crossSystem = {
        config = "aarch64-unknown-linux-gnu";
        gcc.arch = "armv8-a";
      };
      modules = [ nixos-raspberrypi.nixosModules.raspberry-pi-5.base ];
    };

    hosts = {
      Bedroom = rpi3Config;
      Kitchen = rpi5Config;
    };

    mkSystem = { system, crossSystem ? {}, hostName, overlays ? [], modules, ... }@args: let
      pkgs = import nixpkgs {
        inherit system overlays crossSystem;
      };
    in nixpkgs.lib.nixosSystem {
      inherit pkgs system;
      modules = [
        { networking.hostName = hostName; }
        nixos-raspberrypi.lib.inject-overlays
        nixos-raspberrypi.nixosModules.trusted-nix-caches
        nixos-raspberrypi.nixosModules.nixpkgs-rpi
        nixos-raspberrypi.nixosModules.sd-image
        nixos-raspberrypi.nixosModules.default
        ./common.nix
      ] ++ modules;
      specialArgs = {
        inherit nixos-raspberrypi;
      };
    };
  in {
    nixosConfigurations = builtins.mapAttrs (name: info: mkSystem (info // { hostName = name; })) hosts;

    images = builtins.mapAttrs (name: value: self.nixosConfigurations.${name}.config.system.build.sdImage) hosts;
  };
}
