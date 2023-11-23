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

{ config, lib, pkgs, unstable, inputs, vars, ... }:

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

  fonts.fonts = with pkgs; [                # Fonts
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
    systemPackages = with pkgs; [           # System-Wide Packages
      # Terminal
      btop              # Resource Manager
      coreutils         # GNU Utilities
      git               # Version Control
      killall           # Process Killer
      nano              # Text Editor
      nix-tree          # Browse Nix Store
      pciutils          # Manage PCI
      ranger            # File Manager
      screen            # Deatach
      tldr              # Helper
      usbutils          # Manage USB
      wget              # Retriever

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

    nodejs_16
    docker-compose
    openvpn
    qbittorrent

      # - ./<host>/default.nix
      # - ../modules
    ] ++
    (with unstable; [
      # Apps
#      firefox           # Browser
    telegram-desktop
    networkmanager_strongswan
      brave
      discord
      stremio
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])
    jetbrains.jdk
    jdk17
    jre17_minimal
#    steam
#    megasync
    ]);
  };

  programs = {
#    dconf.enable = true;
#    openvpn3.enable = true;
#    gamemode.enable = true;
    java.enable = true;
  };
  nixpkgs.config.permittedInsecurePackages = [
                  "nodejs-16.20.2"
                ];

  services = {
    printing = {                            # CUPS
      enable = true;
    };
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
    #  enable = true;
    #  channel = "https://nixos.org/channels/nixos-unstable";
    #};
    stateVersion = "23.05";
  };

  home-manager.users.${vars.user} = {       # Home-Manager Settings
    home = {
      stateVersion = "23.05";
    };

    programs = {
      home-manager.enable = true;
    };
  };
  flatpak.enable = true;
    flatpak = {                                   # Flatpak Packages (see module options)
      extraPackages = [
        "com.github.tchx84.Flatseal"
        "com.ultimaker.cura"
        "org.upscayl.Upscayl"
      ];
    };

    nixpkgs.overlays = [                          # Overlay pulls latest version of Discord
      (final: prev: {
        discord = prev.discord.overrideAttrs (
          _: { src = builtins.fetchTarball {
            url = "https://discord.com/api/download?platform=linux&format=tar.gz";
            sha256 = "0pml1x6pzmdp6h19257by1x5b25smi2y60l1z40mi58aimdp59ss";
          };}
        );
      })
    ];
#  #enable scripts with shebang !# /bin/bash
#  system.activationScripts.binbash = {
#      deps = [ "binsh" ];
#      text = ''
#           ln -s /bin/sh /bin/bash
#      '';
#    };

#VPN setup https://www.reddit.com/r/NixOS/comments/olou0x/using_vpn_on_nixos/
networking.wg-quick.interfaces = {
ch-surf = {
#  autoStart = false;
  address = [ "89.37.173.41" ];
  dns = [ "ch-zur.prod.surfshark.com" ]; # mullvad public dns
  privateKeyFile = "/home/caldetas/Downloads/ch-zur.conf";
  peers = [
    {
      publicKey = "qFuwaE8IyDbNBTNar3xAXRGaBdkTtmLh1uIGMJxTxUs=";
      allowedIPs = [ "0.0.0.0/0" ]; # Only send communication through mullvad if it is in the range of the given ips, allows for split tunneling
      endpoint = "ch-zur.prod.surfshark.com:
      51820"; # my selected mullvad enpoint
    }
  ];
};
};
  services.openvpn.servers = {
    suiza = {
      autoStart = false;
      # TODO put vpn files somewhere better or move config here.
      config = "config ~/Downloads/ch-zur.prod.surfshark.comsurfshark_openvpn_udp.ovpn";
    };
  };
  environment.etc = {
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
}
