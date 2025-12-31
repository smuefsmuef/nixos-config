# hosts/configuration.nix
# Haupt-Systemkonfiguration (Flake-style).
# Passe vars / inputs in deinem Flake an (dieses File ist als modulare Host-Konfig gedacht).

{ config, lib, pkgs, unstable, inputs, vars, sops-nix, ... }:

let
  # Module-Ordner (dein repo-layout: modules/{desktops,editors,...})
  desktopModules = import ../modules/desktops;
  editorModules  = import ../modules/editors;
  hardwareModules = import ../modules/hardware;
  programModules = import ../modules/programs;
  serviceModules = import ../modules/services;
  shellModules = import ../modules/shell;
  themeModules = import ../modules/theming;

  # alle Module zusammenfassen (vermeidet verschachtelte Listen-Probleme)
  allModuleFolders = lib.concatLists [
    desktopModules
    editorModules
    hardwareModules
    programModules
    serviceModules
    shellModules
    themeModules
  ];
in
{
  ####################################################################
  ## Imports: home-manager + sops + deine modul-ordner
  ####################################################################
  imports = lib.concatLists [
    [ inputs.sops-nix.nixosModules.sops inputs.home-manager.nixosModules.home-manager ]
    allModuleFolders
  ];

  ####################################################################
  ## SOPS (secrets)
  ####################################################################
  sops.secrets."home-path" = { };
  sops.secrets."my-secret" = {
    owner = "${vars.user}";
  };

  users.groups.secrets = { };

  users.users."${vars.user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "camera" "networkmanager" "lp" "scanner" "secrets" ];
  };

  ####################################################################
  ## Lokalisation / Zeit
  ####################################################################
  time.timeZone = "Europe/Zurich";
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

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024; # 16GB
    }
  ];

  ####################################################################
  ## Sicherheit
  ####################################################################
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  ####################################################################
  ## Fonts — nerdfonts entfernt (verursachte Fehler)
  ####################################################################
  fonts.packages = with pkgs; [
    carlito
    vegur
    source-code-pro
    jetbrains-mono
    font-awesome
    corefonts
    ubuntu_font_family
  ];

  # Enforce Fontconfig (wie vorher)
  fonts.fontconfig.enable = lib.mkForce true;

  ####################################################################
  ## Network / Nameserver
  ####################################################################
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  ####################################################################
  ## Environment / systemPackages
  ####################################################################
  environment = {
    variables = {
      TERMINAL = "${vars.terminal}";
      EDITOR   = "${vars.editor}";
      VISUAL   = "${vars.editor}";
    };

    systemPackages = with pkgs; [
      # Basics
      btop coreutils git glxinfo hwinfo killall lshw nano nix-tree nixpkgs-fmt pciutils psmisc
      ranger screen tldr usbutils wget xdg-utils binutils vscode

      # Passwords / crypto
      pass gnupg pinentry

      # Audio / Video / Design
      alsa-utils audacity feh mpv pavucontrol pipewire pulseaudio vlc openshot-qt figma-linux

      # Apps
      appimage-run google-chrome libreoffice vivaldi

      # File-management
      file-roller pcmanfm p7zip rsync unzip unrar zip pdfarranger

      # Security / tooling
      sops yarn slack

      # Java / build
      gradle maven python3 libGL php php82Packages.composer

      # 3d / processing
      processing mesa jogl

      # Other apps
      brave discord docker-compose firefox gedit git gimp gparted quickemu htop lsof
      netbird netbird-ui openvpn qbittorrent remmina spotify steam stremio strongswan
      megasync openssl clockify postman
    ] ++ (with unstable; [
      # Optional unstable pkgs can be appended here
    ]);
  };

  ####################################################################
  ## Programs
  ####################################################################
  programs = {
    gamemode.enable = false;
    java.enable = true;
  };

  ####################################################################
  ## Nix / flake / GC config
  ####################################################################
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    package = pkgs.nixVersions.latest;
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ "freeimage-unstable-2021-11-01" ];
  };

  ####################################################################
  ## Hardware / Services
  ####################################################################
  hardware.pulseaudio.enable = false;

  services = {
    printing.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse = { enable = true; };
      jack  = { enable = true; };
    };

    openssh = {
      enable = true;
      allowSFTP = true;
      extraConfig = ''
        HostKeyAlgorithms +ssh-rsa
      '';
    };

    strongswan.enable = true;
    netbird.enable = true;
  };

  ####################################################################
  ## System / activation script / stateVersion
  ####################################################################
  system.activationScripts = {
    text = ''
      # Check if sops encryption is working
      echo "Hey ${vars.user}! This proves sops is working." > /home/${vars.user}/secretProof.txt
      echo $(cat ${config.sops.secrets.my-secret.path}) >> /home/${vars.user}/secretProof.txt || true
      echo "My home-path on this computer:" >> /home/${vars.user}/secretProof.txt
      echo $(cat ${config.sops.secrets.home-path.path}) >> /home/${vars.user}/secretProof.txt || true
    '';
  };

  system.stateVersion = "25.05";

  ####################################################################
  ## Home-manager (minimal, damit home-manager module funktionieren)
  ####################################################################
  home-manager.users."${vars.user}" = {
    home.stateVersion = "25.05";
  };

  ####################################################################
  ## XDG defaults, firewall ports etc.
  ####################################################################
  xdg.mime.defaultApplications = {
    "image/jpeg" = [ "image-roll.desktop" "feh.desktop" ];
    "image/png"  = [ "image-roll.desktop" "feh.desktop" ];
    "text/plain" = "org.gnome.gedit.desktop";
    "text/html"  = "brave-browser.desktop";
    "text/csv"   = "org.gnome.gedit.desktop";
    "application/pdf" = "brave-browser.desktop";
    "application/zip" = "org.gnome.FileRoller.desktop";
    "application/x-tar" = "org.gnome.FileRoller.desktop";
  };

  networking.firewall.allowedTCPPorts = [ 9003 ];
  environment.etc.hosts.mode = "0644";

  environment.interactiveShellInit = ''
    alias buildVm='echo cd ${vars.location} && git pull && sudo nixos-rebuild build-vm --flake ${vars.location}#vm --show-trace --update-input nixpkgs'
  '';
}
