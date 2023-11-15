#
#  Specific system configuration settings for libelula
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ ./libelula
#   │        ├─ default.nix *
#   │        └─ hardware-configuration.nix
#   └─ ./modules
#       └─ ./desktops
#           ├─ bspwm.nix
#           └─ ./virtualisation
#               └─ docker.nix
#

{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktops/virtualisation/docker.nix
  ];

  boot = {                                  # Boot Options
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {                              # Grub Dual Boot
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;                 # Find All Boot Options
        configurationLimit = 2;
      };
      timeout = 1;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  hardware.sane = {                         # Scanning
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  laptop.enable = true;                     # Laptop Modules
  bspwm.enable = true;                      # Window Manager

  environment = {
    systemPackages = with pkgs; [           # System-Wide Packages
      simple-scan       # Scanning
      onlyoffice-bin    # Office
    ];
  };
}
