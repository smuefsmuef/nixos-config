#
#  flake.nix *             
#   ├─ ./hosts
#   │   └─ default.nix
#   └─ ./nix
#       └─ default.nix
#

{
  description = "Nix & NixOS System Flake Configuration";

  inputs =                                                                  # References Used by Flake
    {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";                  # Unstable Nix Packages (Default)
      nixpkgs-stable.url = "github:nixos/nixpkgs/release-23.11";            # Stable Nix Packages
      rust-overlay.url = "github:oxalica/rust-overlay";

      home-manager = {                                                      # User Environment Manager
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nur = {                                                               # NUR Community Packages
        url = "github:nix-community/NUR";                                   # Requires "nur.nixosModules.nur" to be added to the host modules
      };

      nixgl = {                                                             # Fixes OpenGL With Other Distros.
        url = "github:guibou/nixGL";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      hyprland = {                                                          # Official Hyprland Flake
        url = "github:hyprwm/Hyprland";                                     # Requires "hyprland.nixosModules.default" to be added the host modules
        inputs.nixpkgs.follows = "nixpkgs";
      };

      plasma-manager = {                                                    # KDE Plasma User Settings Generator
        url = "github:pjones/plasma-manager";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.home-manager.follows = "nixpkgs";
      };
    };

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, home-manager, nur, nixgl, hyprland, plasma-manager, ... }:   # Function telling flake which inputs to use
    let
      vars = {                                                              # Variables Used In Flake
        user = "caldetas";
        location = "$HOME/Desktop/nixos-config";
        terminal = "kitty";
        editor = "nano";
      };
      
            nixpkgs-patched = (import nixpkgs
            ).applyPatches {
                      name = "fix-strongswan.patch";
                      url = "https://github.com/caldetas/nixpkgs/commit/e2573b8534b39b627d318e685268acf6b20ffce4.patch";
                      hash = "sha256-rClVIqSN8ZXKlakyyRK+p8uwiy3w9EvxDqwQlJyPX0c=";
            };
            pkgs = import nixpkgs-patched;

            nixpkgs-stable-patched = (import nixpkgs-stable
            ).applyPatches {
                      name = "fix-strongswan.patch";
                      url = "https://github.com/caldetas/nixpkgs-stable/commit/e2573b8534b39b627d318e685268acf6b20ffce4.patch";
                      hash = "sha256-rClVIqSN8ZXKlakyyRK+p8uwiy3w9EvxDqwQlJyPX0c=";
            };
            stable = import nixpkgs-stable-patched;

    in
    {
      nixosConfigurations = (                                               # NixOS Configurations
        import ./hosts {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-stable home-manager nur hyprland plasma-manager vars;   # Inherit inputs
        }
      );

      homeConfigurations = (                                                # Nix Configurations
        import ./nix {
          inherit (nixpkgs) lib;
          inherit inputs nixpkgs nixpkgs-stable home-manager nixgl vars;
        }
      );
    };
}
