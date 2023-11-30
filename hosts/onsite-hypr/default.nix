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
#  services.xserver.enable = true;







  hyprland.enable = true;
#  programs.hyprland.enable = true;
#  programs.hyprland.nvidiaPatches = true;
#  programs.hyprland.xwayland.enable = true;
#
#  environment.sessionVariables.LIBVA_DRIVER_NAME="nvidia";
#  environment.sessionVariables.CLUTTER_BACKEND="wayland";
#  environment.sessionVariables.XDG_SESSION_TYPE="wayland";
#  environment.sessionVariables.QT_WAYLAND_DISABLE_WINDOWDECORATION="1";
#  environment.sessionVariables.MOZ_ENABLE_WAYLAND="1";
#  environment.sessionVariables.GBM_BACKEND="nvidia-drm";
#  environment.sessionVariables.__GLX_VENDOR_LIBRARY_NAME="nvidia";
#  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS="1";
#  environment.sessionVariables.WLR_BACKEND="vulkan";
#  environment.sessionVariables.QT_QPA_PLATFORM="wayland";
#  environment.sessionVariables.GDK_BACKEND="wayland";
#  environment.sessionVariables.LIBSEAT_BACKEND="logind";
#  environment.sessionVariables.WLR_RENDERER_ALLOW_SOFTWARE="1";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      libsForQt5.qt5ct
      libva
      intel-compute-runtime
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  }

