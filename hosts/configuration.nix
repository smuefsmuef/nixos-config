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

#  time.timeZone = "America/Mexico_City";        # Time zone and Internationalisation
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
#  fonts.fontconfig.enable = true;
  fonts.fontconfig.enable = lib.mkForce true;

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
      libreoffice       # OpenOffice


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
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])

      # - ./<host>/default.nix
      # - ../modules
    ] ++
    (with pkgs; [
      # Apps
      firefox           # Browser
      authy
      telegram-desktop
      spotify
      networkmanager_strongswan
      brave
      discord
      stremio
      gimp
      gedit
      gnupg1orig
      gnome.gnome-remote-desktop
      remmina

#      jdk17
      jetbrains.jdk
      jre17_minimal
      jetbrains.pycharm-professional
      jetbrains.datagrip
      python3
      catppuccin-papirus-folders
      catppuccin-gtk
      steam

    #CV creation with Latex
#    texlive.combined.scheme-full

    megasync
    ]);
  };

  programs = {
    gamemode.enable = true;
    java.enable = true;
  };

    nixpkgs.config.permittedInsecurePackages = [
              "nodejs-16.20.2"
              "electron-25.9.0"
              "freeimage-unstable-2021-11-01"
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
        "io.github.mimbrero.WhatsAppDesktop"
        "org.signal.Signal"
      ];
    };

  services.strongswan.enable = true;
  environment.etc = with pkgs; {
    # Creates /etc/strongswan.conf necessary for vpn
    "strongswan.conf".text = ''
    # strongswan.conf - strongSwan configuration file
    #
    # Refer to the strongswan.conf(5) manpage for details
    #
    # Configuration changes should be made in the included files

    charon {
    	load_modular = yes
    	plugins {
    		include strongswan.d/charon/*.conf
    	}
    }

    include ${pkgs.networkmanager_strongswan}/etc/strongswan.d/*.conf

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
      '';
  /*  # Creates /etc/strongswan.conf necessary for vpn NOT ALLOWED..
    "${pkgs.networkmanager_strongswan}/etc/".text = ''
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
      '';*/
    "xdg/gtk-2.0/gtkrc".text = "gtk-error-bell=0";
    "xdg/gtk-3.0/settings.ini".text = ''
      gtk-prefer-dark-theme=true
      gtk-error-bell=false
    '';
    "xdg/gtk-4.0/settings.ini".text = ''
      gtk-prefer-dark-theme=true
      gtk-error-bell=false
    '';
      };

system.activationScripts = { text =
                           ''
                             # Set up automated scripts if not existing
                             if grep -q 'MEGAsync/work/programs'  /home/caldetas/.zshrc
                             then
                                echo "scripts already set up in zshrc";
                             else
                                echo 'chmod +x ~/MEGAsync/work/programs/*
                                export PATH=$PATH:/home/caldetas/MEGAsync/work/programs' >> /home/caldetas/.zshrc
                                echo "set up scripts in zshrc";
                             fi
                           '';

                         };
}
