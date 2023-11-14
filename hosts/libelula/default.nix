#  Specific system configuration settings for libelula
>>>>>>> 451c90c (try)
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

{ pkgs, config, lib, unstable, inputs, vars, modulesPath, host, ... }:

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


  services.strongswan.enable = true;



  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system. (gnome?)
  services.xserver.enable = true;




  # Enable the GNOME Desktop Environment.
#  services.xserver.displayManager.gdm.enable = true;
#  services.xserver.desktopManager.gnome.enable = true;
  gnome.enable = true;
#  hyprland.enable = true;
#  bspwm.enable = true;
#laptop.enable = true;                     # Laptop Modules

  # Configure keymap in X11
#  services.xserver = {
#    layout = "ch";
#    xkbVariant = "de_nodeadkeys";
#  };


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).

/*  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.caldetas = {
    isNormalUser = true;
    description = "caldetas";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      pciutils
    ];
  };*/

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  ### graphic card





  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

  mesa #elden ring
  directx-headers #elden ring
  directx-shader-compiler #elden ring
  ];

  #Steam
  programs.steam.enable = true;
  programs.gamemode.enable = true;

  #java
  programs.java.enable = true;
  nixpkgs.config.permittedInsecurePackages = [
                "nodejs-16.20.2"
              ];
  virtualisation.docker.enable = true;

  #Shortcuts
  programs.openvpn3.enable = true;

  programs.dconf = {
  enable = true;
  };




  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

=======
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

#  programs.light.enable = true;             # Monitor Brightness
#
#  services = {
#    printing = {                            # Printing and drivers for TS5300
#      enable = true;
#      drivers = [ pkgs.cnijfilter2 ];
#    };
#  };
#
  flatpak = {                               # Flatpak Packages (see module options)
    extraPackages = [
      "com.github.tchx84.Flatseal"
    ];
  };
#
#  systemd.tmpfiles.rules = [                # Temporary Bluetooth Fix
#    "d /var/lib/bluetooth 700 root root - -"
#  ];
#  systemd.targets."bluetooth".after = ["systemd-tmpfiles-setup.service"];
}
