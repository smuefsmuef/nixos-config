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

{ pkgs, config, lib, unstable, inputs, vars, host, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nvidia.nix
      ../../modules/desktops/virtualisation/docker.nix
    ] ++
    ( import ../../modules/desktops ++
                      import ../../modules/editors ++
                      import ../../modules/hardware ++
                      import ../../modules/programs ++
                      import ../../modules/services ++
                      import ../../modules/shell ++
                      import ../../modules/theming );

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.grub.useOSProber = true;

#  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      enableCryptodisk = true;
      device = "nodev";
      useOSProber = true;
      configurationLimit = 20;
      default=0;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

#  networking.hostName = hostname; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.





  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system. (gnome?)
#  services.xserver.enable = true;




  # Enable the GNOME Desktop Environment.
#  services.xserver.displayManager.gdm.enable = true;
#  services.xserver.desktopManager.gnome.enable = true;
  gnome.enable = true;
#  hyprland.enable = true;
#  bspwm.enable = true;
#laptop.enable = true;                     # Laptop Modules



#  # Enable CUPS to print documents.
#  services.printing.enable = true;
#
#  # Enable sound with pipewire. (needed for gnome.enabled)
#  sound.enable = true;
#  hardware.pulseaudio.enable = false;
#  security.rtkit.enable = true;
#  services.pipewire = {
#    enable = true;
#    alsa.enable = true;
#    alsa.support32Bit = true;
#    pulse.enable = true;
#  };
#
#  # Allow unfree packages
#  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

  mesa #elden ring
  directx-headers #elden ring
  directx-shader-compiler #elden ring
  ];
#  programs.git = {
##        enable = true;
#  #          userName = "caldetas";
#  #          userEmail = "misterhannes@hotmail.com";
#            includes = [
#              { # onsite
#                condition = "gitdir:~/Desktop/db2020-backend";
#                contents.user = {
#                  email = "hannes.graf@onsite.ch";
#                  name = "Hannes Graf";
#                };
#              }
#            ];
#          };
#
#  #java
#  programs.java.enable = true;
#  nixpkgs.config.permittedInsecurePackages = [
#                "nodejs-16.20.2"
#              ];
#
#  programs.dconf = {
#  enable = true;
#  };
}

