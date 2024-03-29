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

{ config, lib, pkgs, stable, inputs, vars, sops-nix, ... }:
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
#let
#strongswan = pkgs.strongswan.overrideAttrs (oldAttrs: {
#    patches = oldAttrs.patches ++ [
#      (pkgs.fetchpatch {
#        name = "fix-strongswan.patch";
#        url = "https://github.com/caldetas/nixpkgs/commit/e2573b8534b39b627d318e685268acf6b20ffce4.patch";
#        hash = "sha256-rClVIqSN8ZXKlakyyRK+p8uwiy3w9EvxDqwQlJyPX0c=";
#     })
#    ];
#  });
#in
{
  imports =
    [
      inputs.sops-nix.nixosModules.sops
    ] ++ (
              import ../modules/desktops ++
              import ../modules/editors ++
              import ../modules/hardware ++
              import ../modules/programs ++
              import ../modules/services ++
              import ../modules/shell ++
              import ../modules/theming
              );



      sops.secrets.home-path = { };
      sops.secrets."surfshark/user" = { };
      sops.secrets."surfshark/password" = { };
      sops.secrets."my-secret" = {
        owner = "${vars.user}";
      };
     users.groups.secrets = { };

  users.users.${vars.user} = {              # System User
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "camera" "networkmanager" "lp" "scanner" "secrets" ];
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

#  networking.nameservers =  [ "1.1.1.1" "9.9.9.9"]; # privacy respecting nameserver for dns queries (cloudflare & quad9)
  networking.nameservers =  [ "162.252.172.57" "149.154.159.92"]; # Surfshark

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
      audacity          # Audio Editor
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

      # Security
      sops


    htop
    gparted
    strongswan
    git
    lshw
    glxinfo
    hwinfo
    nodejs_18
    docker-compose
    openvpn
    qbittorrent

    #Java
    gradle
    jetbrains.jdk

    ] ++
    (with pkgs; [
      # Apps
      firefox           # Browser
      authy
      telegram-desktop
      spotify
      brave
      discord
      stremio
      gimp
      gedit
      gnupg1orig
      gnome.gnome-remote-desktop
      netbird
      netbird-ui
      remmina
      teams-for-linux


#      jdk17
      (jetbrains.plugins.addPlugins jetbrains.idea-ultimate [ "github-copilot" ])
      jre17_minimal
      jetbrains.pycharm-professional
      jetbrains.datagrip
      python3
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
               "freeimage-unstable-2021-11-01"
            ];
  hardware.pulseaudio.enable = false;
  services = {
    printing.enable = true;
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
  services.netbird.enable = true;



    #Default Applications
    xdg.mime.defaultApplications = {
            "image/jpeg" = ["image-roll.desktop" "feh.desktop"];
            "image/png" = ["image-roll.desktop" "feh.desktop"];
            "text/plain" = "org.gnome.gedit.desktop";
            "text/html" = "brave-browser.desktop";
            "text/csv" = "org.gnome.gedit.desktop";
            "application/pdf" =  "brave-browser.desktop";
            "application/zip" = "org.gnome.FileRoller.desktop";
            "application/x-tar" = "org.gnome.FileRoller.desktop";
            "application/x-bzip2" = "org.gnome.FileRoller.desktop";
            "application/x-gzip" = "org.gnome.FileRoller.desktop";
            "x-scheme-handler/http" = ["brave-browser.desktop" "firefox.desktop"];
            "x-scheme-handler/https" = ["brave-browser.desktop" "firefox.desktop"];
            "x-scheme-handler/about" = ["brave-browser.desktop" "firefox.desktop"];
            "x-scheme-handler/unknown" = ["brave-browser.desktop" "firefox.desktop"];
            "x-scheme-handler/mailto" = ["brave-browser.desktop"];
            "audio/mp3" = "vlc.desktop";
            "audio/x-matroska" = "vlc.desktop";
            "video/webm" = "vlc.desktop";
            "video/mp4" = "vlc.desktop";
            "video/x-matroska" = "vlc.desktop";
  };


  # SOPS Configuration Secrets
  sops.defaultSopsFile = ./../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${vars.user}/MEGAsync/encrypt/nixos/keys.txt";
  system.activationScripts = { text =
                           ''

                            # Check if sops encryption is working
                            echo '
                            Hey man! I am proof the encryption is working!

                            My secret is here:
                            ${config.sops.secrets.my-secret.path}

                            My secret value is not readable, only in a shell environment:'  > /home/${vars.user}/secretProof.txt
                            echo $(cat ${config.sops.secrets.my-secret.path}) >> /home/${vars.user}/secretProof.txt

                            echo '
                            My home-pathon this computer:' >> /home/${vars.user}/secretProof.txt
                            echo $(cat ${config.sops.secrets.home-path.path}) >> /home/${vars.user}/secretProof.txt

                            #make openVpn surfshark login credential file
                            mkdir /home/${vars.user}/.secrets
                            echo $(cat ${config.sops.secrets."surfshark/user".path}) > /home/${vars.user}/.secrets/openVpnPass.txt
                            echo $(cat ${config.sops.secrets."surfshark/password".path}) >> /home/${vars.user}/.secrets/openVpnPass.txt


                             # Set up automated scripts if not existing                          # folder exists??
                             if [ grep -q 'MEGAsync/work/programs'  /home/caldetas/.zshrc ]  && [ -d "/home/${vars.user}/MEGAsync/work/programs" ];
                             then
                                echo "scripts already set up in zshrc";
                             else
                                echo
                                    '
                                    chmod +x ~/MEGAsync/work/programs/*
                                    export PATH=$PATH:/home/caldetas/MEGAsync/work/programs
                                    ' >> /home/caldetas/.zshrc
                                echo "set up scripts in zshrc";
                             fi
                           '';

                         };
}
