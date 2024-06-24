#
#  Specific system configuration settings for onsite-gnome
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ ./onsite-gnome
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

#   Bootloader. setup for new bios
   boot.loader.systemd-boot.enable = true;
   boot.loader.efi.canTouchEfiVariables = true;
   boot.loader.grub.useOSProber = true;


#  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];
 /* boot.loader = {
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
  };*/


  networking.hostName = host.hostName; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.





  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
#  networking.networkmanager.enableStrongSwan = true;

  # Enable the X11 windowing system. (gnome?)  // todo here
#  services.xserver.enable = true;

services.xserver.displayManager.sessionCommands = ''
    ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
'';

/*
for displaylink hub run:
nix-prefetch-url --name displaylink-580.zip https://www.synaptics.com/sites/default/files/exe_files/2023-08/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu5.8-EXE.zip
 mv $PWD/"DisplayLink USB Graphics Software for Ubuntu6.0-EXE.zip" $PWD/displaylink-580.zip > nix-prefetch-url file://$PWD/displaylink-580.zip*/


  # Enable the GNOME Desktop Environment.
#  services.xserver.displayManager.gdm.enable = true;
#  services.xserver.desktopManager.gnome.enable = true;
gnome.enable = true;
#hyprland.enable = true;
#  bspwm.enable = true;
#laptop.enable = true;                     # Laptop Modules



#  # Enable CUPS to print documents.
#  services.printing.enable = true;
#
 services.printing.drivers = with pkgs; [
    cnijfilter2
    ]; # Canon Printer


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


environment.interactiveShellInit = ''
  alias commit='echo cd ${vars.location} \&\& git pull \&\& sudo systemctl unmask  -- -.mount \&\& sudo systemctl daemon-reload \&\& sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace --update-input nixpkgs --commit-lock-file && cd ${vars.location} && git pull && sudo systemctl unmask  -- -.mount && sudo systemctl daemon-reload && sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace --update-input nixpkgs --commit-lock-file'
  alias update='echo cd ${vars.location} \&\& git pull \&\& sudo systemctl unmask  -- -.mount \&\& sudo systemctl daemon-reload \&\& sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace --update-input nixpkgs && cd ${vars.location} && git pull && sudo systemctl unmask  -- -.mount && sudo systemctl daemon-reload && sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace --update-input nixpkgs'
  alias rebuild='echo cd ${vars.location} \&\& git pull \&\& sudo systemctl unmask  -- -.mount \&\& sudo systemctl daemon-reload \&\& sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace && cd ${vars.location} && git pull && sudo systemctl unmask  -- -.mount && sudo systemctl daemon-reload && sudo nixos-rebuild switch --flake ${vars.location}#${host.hostName} --show-trace'
  alias remminaResetRDP='rm -fr ~/.config/remmina && rm -f ~/.config/freerdp/known_hosts2'
'';



}

