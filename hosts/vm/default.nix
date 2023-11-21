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

{ pkgs, config, lib, unstable, inputs, vars, modulesPath, host, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/desktops/virtualisation/docker.nix
    ] ++
    ( import ../../modules/desktops ++
                      import ../../modules/editors ++
                      import ../../modules/hardware ++
                      import ../../modules/programs ++
                      import ../../modules/services ++
                      import ../../modules/shell ++
                      import ../../modules/theming
                      );

  users.users.${vars.user} = {              # System User
    initialPassword = "test";
    group = "test";
    extraGroups = [ "wheel" "video" "audio" "camera" "networkmanager" "lp" "scanner" ];
  };
  users.groups.test = {};

  boot = {                                      # Boot Options
    loader = {
      grub = {
        enable = true;
        device = "/dev/vda";
      };
      timeout = 1;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  bspwm.enable = true;                          # Window Manager
  security.rtkit.enable = true;
 /* gnome.enable = true;                          # Window Manager
#  laptop.enable = true;                          # Window Manager

    # Enable sound with pipewire. (needed for gnome.enabled)
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    */
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

        virtualisation.vmVariant = {
          # following configuration is added only when building VM with build-vm
          virtualisation = {
            memorySize =  8192; # Use 8192 memory.
            cores = 4;
          };
      };

  environment = {
    systemPackages = with pkgs; [               # System Wide Packages
      hello             # Test Package
    ];
  };

  services = {
    xserver = {
      enable = true;
      resolutions = [
        { x = 1920; y = 1080; }
#        { x = 1600; y = 900; }
#        { x = 3840; y = 2160; }
      ];
    };
  };
}
