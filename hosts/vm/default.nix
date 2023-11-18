#
#  Specific system configuration settings for vm
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ ./vm
#   │       ├─ default.nix *
#   │       └─ hardware-configuration.nix
#   └─ ./modules
#       └─ ./desktops
#           └─ bspwm.nix
#

{ config, pkgs, vars, ... }:

{
  imports =  [
    ./hardware-configuration.nix
  ];

  boot = {                                      # Boot Options
    loader = {
      grub = {
        enable = true;
        device = "/dev/disk/by-uuid/8ebc37ae-f64a-47d1-9df4-2a1f2ee6f65f";
      };
      timeout = 1;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  bspwm.enable = true;                          # Window Manager

  environment = {
    systemPackages = with pkgs; [               # System Wide Packages
      hello             # Test Package
    ];
  };

  services = {
    xserver = {                                 
      resolutions = [
        { x = 1920; y = 1080; }
        { x = 1600; y = 900; }
        { x = 3840; y = 2160; }
      ];
    };
  };
}
