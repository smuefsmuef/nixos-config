#
#  Main system configuration. More information available in configuration.nix(5) man page.
#
#  flake.nix
#   ├─ ./hosts
#   │   ├─ default.nix
#   │   └─ configuration.nix *
#   └─ ./modules
#       ├─ ./desktops
#       │   └─ default.nix
#       ├─ ./editors
#       │   └─ default.nix
#       ├─ ./hardware
#       │   └─ default.nix
#       ├─ ./programs
#       │   └─ default.nix
#       ├─ ./services
#       │   └─ default.nix
#       ├─ ./shell
#       │   └─ default.nix
#       └─ ./theming
#           └─ default.nix
#

{ config, lib, pkgs, stable, inputs, vars, ... }:
#let
#     pkgsM = import (builtins.fetchGit {
#         # Descriptive name to make the store path easier to identify
#         name = "my-old-nodeJs";
#         url = "https://github.com/NixOS/nixpkgs/";
#         ref = "refs/heads/nixpkgs-unstable";
#         rev = "9957cd48326fe8dbd52fdc50dd2502307f188b0d";
#     }) {};
#
#     nodeV16 = pkgsM.nodejs_16;
#in

{
  imports = (
              import ../modules/desktops ++
              import ../modules/editors ++
              import ../modules/hardware ++
              import ../modules/programs ++
              import ../modules/services ++
              import ../modules/shell ++
              import ../modules/theming
              );

  users.users.${vars.user} = {              # System User
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "camera" "networkmanager" "lp" "scanner" ];
  };

  time.timeZone = "Europe/Zurich";        # Time zone and Internationalisation
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "sg";
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  fonts.packages = with pkgs; [                # Fonts
    carlito                                 # NixOS
    vegur                                   # NixOS
    source-code-pro
    jetbrains-mono
    font-awesome                            # Icons
    corefonts                               # MS
    ubuntu_font_family
    (nerdfonts.override {                   # Nerdfont Icons override
      fonts = [
        "FiraCode"
      ];
    })
  ];

  environment = {
    variables = {                           # Environment Variables
      TERMINAL = "${vars.terminal}";
      EDITOR = "${vars.editor}";
      VISUAL = "${vars.editor}";
    };
    systemPackages = with stable; [           # System-Wide Packages
      # Terminal
      btop              # Resource Manager
      coreutils         # GNU Utilities
      git               # Version Control
      killall           # Process Killer
      nano              # Text Editor
      nix-tree          # Browse Nix Store
      nixpkgs-fmt       # Formatter for nix files
      pciutils          # Manage PCI
      ranger            # File Manager
      screen            # Deatach
      tldr              # Helper
      usbutils          # Manage USB
      wget              # Retriever
      xdg-utils         # Environment integration
      psmisc            # A set of small useful utilities that use the proc filesystem (such as fuser, killall and pstree)

      # Video/Audio
      alsa-utils        # Audio Control
      feh               # Image Viewer
      mpv               # Media Player
      pavucontrol       # Audio Control
      pipewire          # Audio Server/Control
      pulseaudio        # Audio Server/Control
      vlc               # Media Player

      # Apps
      appimage-run      # Runs AppImages on NixOS
      google-chrome     # Browser
      remmina           # XRDP & VNC Client

      # File Management
      gnome.file-roller # Archive Manager
      okular            # PDF Viewer
      pcmanfm           # File Browser
      p7zip             # Zip Encryption
      rsync             # Syncer - $ rsync -r dir1/ dir2/
      unzip             # Zip Files
      unrar             # Rar Files
      zip               # Zip


    htop
    gparted
    gnome.gedit
    gnome.gnome-tweaks
    yaru-theme
    git
    lshw
    glxinfo
    hwinfo
    nodejs_18
    docker-compose
    openvpn
    qbittorrent

      # - ./<host>/default.nix
      # - ../modules
    ] ++
    (with pkgs; [
      # Apps
#      firefox           # Browser
    telegram-desktop
#    whatsapp-for-linux
    networkmanager_strongswan
      brave
      discord
      stremio
      gimp

#      jetbrains.jdk
      jdk17
      jre17_minimal
      jetbrains.pycharm-professional
      jetbrains.datagrip
#      nodejs-16_x
      catppuccin-papirus-folders
      catppuccin-gtk
      steam
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])

#    steam
#    megasync
#    ])++
#    (with pkgsM; [
#    nodeV16
    ]);
  };

  programs = {
#    dconf.enable = true;
#    openvpn3.enable = true;
    gamemode.enable = true;
    java.enable = true;
  };
networking.networkmanager.enableStrongSwan = true;
services.strongswan-swanctl.enable = true;
services.strongswan-swanctl.strongswan.extraConfig = ''
charon-nm {
           plugins {
             eap-peap {
               load = no
             }
             eap-md5 {
               load = no
             }
             eap-gtc {
               load = no
             }
           }
}
                                                                ''; # Strongswan config to append

    nixpkgs.config.permittedInsecurePackages = [
              "nodejs-16.20.2"
              "electron-25.9.0"
            ];
  hardware.pulseaudio.enable = false;
  services = {
    printing.enable = true;
#    strongswan.enable = true;
    pipewire = {                            # Sound
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
    openssh = {                             # SSH
      enable = true;
      allowSFTP = true;                     # SFTP
      extraConfig = ''
        HostKeyAlgorithms +ssh-rsa
      '';
    };
  };

  nix = {                                   # Nix Package Manager Settings
    settings ={
      auto-optimise-store = true;
    };
    gc = {                                  # Garbage Collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixVersions.unstable;    # Enable Flakes
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    '';
  };
  nixpkgs.config.allowUnfree = true;        # Allow Proprietary Software.

  system = {                                # NixOS Settings
    #autoUpgrade = {                        # Allow Auto Update (not useful in flakes)
    #  enable = true;c
    #  channel = "https://nixos.org/channels/nixos-unstable";
    #};
    stateVersion = "23.11";
  };

  home-manager.users.${vars.user} = {       # Home-Manager Settings
    home = {
      stateVersion = "23.11";
    };
    programs = {
      home-manager.enable = true;
    };
  };
  flatpak.enable = true;
    flatpak = {                                   # Flatpak Packages (see module options)
      extraPackages = [
        "com.github.tchx84.Flatseal"
#        "com.github.eneshecan.WhatsAppForLinux"
        "io.github.mimbrero.WhatsAppDesktop"
      ];
    };

    nixpkgs.overlays = [                          # Overlay pulls latest version of Discord
#      (final: prev: {
#        discord = prev.discord.overrideAttrs (
#          _: { src = builtins.fetchTarball {
#            url = "https://discord.com/api/download?platform=linux&format=tar.gz";
#            sha256 = "1xjk77g9lj5b78c1w3fj42by9b483pkbfb41yzxrg4p36mnd2hkn";
#          };}
#        );
#      })
#      (final: prev: {
#        nodejs_16 = prev.nodejs_16.overrideAttrs (
#          _: { src = builtins.fetchTarball {
#            url = "https://nodejs.org/dist/v16.20.2/win-x64/node.exe";
#            sha256 = "874463523f26ed528634580247f403d200ba17a31adf2de98a7b124c6eb33d87";
#          };}
#        );
#      })
    ];
#  #enable scripts with shebang !# /bin/bash
#  system.activationScripts.binbash = {
#      deps = [ "binsh" ];
#      text = ''
#           ln -s /bin/sh /bin/bash
#      '';
#    };

#VPN setup https://www.reddit.com/r/NixOS/comments/olou0x/using_vpn_on_nixos/
#networking.wg-quick.interfaces = {
#ch-surf = {
##  autoStart = false;
#  address = [ "89.37.173.41" ];
#  listenPort = 51820;
#  privateKeyFile = "/home/caldetas/Downloads/ch-zur.conf";
#  peers = [
#    {
#      publicKey = "qFuwaE8IyDbNBTNar3xAXRGaBdkTtmLh1uIGMJxTxUs=";
#      allowedIPs = [ "0.0.0.0/0" ]; # Only send communication through mullvad if it is in the range of the given ips, allows for split tunneling
##      endpoint = "51820"; # my selected mullvad enpoint
#       persistentKeepalive = 25; # make sure nat tables are always fresh
#    }
#  ];
#};
#};
  services.openvpn.servers = {
    suiza = {
      autoStart = false;
      # TODO put vpn files somewhere better or move config here.
      config = "config ~/Downloads/ch-zur.prod.surfshark.comsurfshark_openvpn_udp.ovpn";
    };
  };
  environment.etc = with pkgs; {
    "xdg/gtk-2.0/gtkrc".text = "gtk-error-bell=0";
    "xdg/gtk-3.0/settings.ini".text = ''
      gtk-prefer-dark-theme=true
      gtk-error-bell=false
    '';
    "xdg/gtk-4.0/settings.ini".text = ''
      gtk-prefer-dark-theme=true
      gtk-error-bell=false
    '';
        "jdk17".source = jdk17_headless;
      };

}
