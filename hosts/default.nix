#
#  These are the different profiles that can be used when building NixOS.
#
#  flake.nix 
#   └─ ./hosts  
#       ├─ default.nix *
#       ├─ configuration.nix
#       └─ ./<host>.nix
#           └─ default.nix 
#

{ lib, inputs, nixpkgs, nixpkgs-stable, home-manager, nur, nixvim, doom-emacs, hyprland, plasma-manager, vars, ... }:

let
  system = "x86_64-linux";                                  # System Architecture

  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;                              # Allow Proprietary Software
  };

  stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };

  lib = nixpkgs.lib;
in
{
  vm = lib.nixosSystem {                                    # VM Profile
    inherit system;
    specialArgs = {
      inherit inputs system stable hyprland vars;
      host = {
        hostName = "vm";
        mainMonitor = "Virtual-1";
        secondMonitor = "";
      };
    };
    modules = [
      nixvim.nixosModules.nixvim
      ./vm
      ./configuration.nix

      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  };

  libelula = lib.nixosSystem {                               #
    inherit system;
    specialArgs = {
      inherit inputs system stable hyprland vars;
#      inherit inputs system unstable vars;
      host = {
        hostName = "libelula";
        mainMonitor = "eDP-1";
        secondMonitor = "HDMI-1";#"HDMI-1-1";
        thirdMonitor = "";
      };
    };
    modules = [
      nur.nixosModules.nur #todo delete?
      ./libelula
      ./configuration.nix

      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${vars.user}.imports = [
          nixvim.homeManagerModules.nixvim
        ];
      }
    ];
  };
  oldie = lib.nixosSystem {                               #
    inherit system;
    specialArgs = {
      inherit inputs system stable hyprland vars;
      host = {
        hostName = "oldie";
        mainMonitor = "eDP-1-1";
        secondMonitor = "";
        thirdMonitor = "";
      };
    };
    modules = [
      ./oldie
      ./configuration.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${vars.user}.imports = [
          nixvim.homeManagerModules.nixvim
        ];
      }
    ];
  };
  hypr-oldie = lib.nixosSystem {                               #
    inherit system;
    specialArgs = {
      inherit inputs system stable hyprland vars;
      host = {
        hostName = "hypr-oldie";
        mainMonitor = "eDP-1-1";
        secondMonitor = "";
        thirdMonitor = "";
      };
    };
    modules = [
      ./hypr-oldie
      ./configuration.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${vars.user}.imports = [
          nixvim.homeManagerModules.nixvim
        ];
      }
    ];
  };
  onsite-gnome = lib.nixosSystem {                               #
    inherit system;
    specialArgs = {
      inherit inputs system stable hyprland vars;
      host = {
        hostName = "onsite-gnome";
        mainMonitor = "eDP-1";
        secondMonitor = "DP-6";
        thirdMonitor = "DP-8";
      };
    };
    modules = [
      ./onsite-gnome
      ./configuration.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${vars.user}.imports = [
          nixvim.homeManagerModules.nixvim
        ];
      }
    ];
  };
}
