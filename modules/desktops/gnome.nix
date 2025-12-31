# modules/desktops/gnome.nix
{ config, lib, pkgs, vars, ... }:

with lib;

{
  options.gnome.enable = mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable GNOME-related config from this module.";
  };

  config = mkIf config.gnome.enable {
    ########################
    # Basic programs
    ########################
    programs = {
      zsh.enable = true;

      # GSConnect (kdeconnect-compatible gnome extension packaged in gnomeExtensions)
      kdeconnect = {
        enable = true;
        package = pkgs.gnomeExtensions.gsconnect;
      };
    };

    ########################
    # X / display manager
    ########################
    services.xserver = {
      enable = true;
      libinput.enable = true;

      xkb = {
        layout = "ch";
      };

      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };

    ########################
    # XRDP (remote desktop via X)
    ########################
    services.xrdp = {
      enable = true;
      defaultWindowManager = "/run/current-system/sw/bin/gnome-session";
      openFirewall = true;
    };

    # Note: do NOT set services.gnome-remote-desktop.enable here (that option may not exist
    # in your nixpkgs version). If you want the package, add pkgs.gnome-remote-desktop to
    # environment.systemPackages or handle it separately.

    ########################
    # udev packages that GNOME expects
    ########################
    # --- Neu: udev-Pakete gehören unter `hardware.udev` ---
    hardware = {
      udev = {
        packages = with pkgs; [
          gnome-settings-daemon
        ];
      };
    };

    ########################
    # System packages for GNOME conveniences
    ########################
    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
      dconf-editor
      gnome-themes-extra
      gnome-tweaks
      # If you want the gnome remote-desktop binary (package only), uncomment:
      # pkgs.gnome-remote-desktop
    ];

    ########################
    # GNOME dconf and home-manager settings for the user
    ########################
    home-manager.users = {
      "${vars.user}" = {
        dconf.settings = {
          "org/gnome/shell" = {
            favorite-apps = [
              "google-chrome.desktop"
              "brave-browser.desktop"
              "firefox.desktop"
              "vivaldi.desktop"
              "discord.desktop"
              "slack.desktop"
              "kitty.desktop"
              "console.desktop"
              "org-gnome-nautilus.desktop"
              "idea-ultimate.desktop"
            ];
            disable-user-extensions = false;
            enabled-extensions = [
              "trayiconsreloaded@selfmade.pl"
              "blur-my-shell@aunetx"
              "drive-menu@gnome-shell-extensions.gcampax.github.com"
              "user-theme@gnome-shell-extensions.gcampax.github.com"
              "dash-to-panel@jderose9.github.com"
              "just-perfection-desktop@just-perfection"
              "caffeine@patapon.info"
              "clipboard-indicator@tudmotu.com"
              "horizontal-workspace-indicator@tty2.io"
              "bluetooth-quick-connect@bjarosze.gmail.com"
              "battery-indicator@jgotti.org"
              "gsconnect@andyholmes.github.io"
              "forge@jmmaranan.com"
            ];
          };

          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            enable-hot-corners = false;
            clock-show-weekday = true;
          };

          # touchpad etc.
          "org/gnome/desktop/peripherals/touchpad" = {
            tap-to-click = true;
          };

          "org/gnome/desktop/input-sources" = {
            sources = [ (lib.gvariant.mkTuple [ "xkb" "ch" ]) ];
          };

          "org/gnome/settings-daemon/plugins/power" = {
            sleep-interactive-ac-type = "nothing";
          };

          "org/gnome/settings-daemon/plugins/media-keys" = {
            custom-keybindings = [
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
              "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            ];
          };

          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
            binding = "<super>t";
            command = "kitty";
            name = "open-terminal";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
            binding = "<ctrl><alt>t";
            command = "kgx";
            name = "default-terminal";
          };
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
            binding = "<super>e";
            command = "nautilus";
            name = "open-file-browser";
          };

          # dash-to-panel / panel settings etc. — keep minimal defaults here
          "org/gnome/shell/extensions" = {
            user-theme = "Orchis-Dark-Compact";
          };
        };

        # install GNOME shell extensions (as packaged in nixpkgs gnomeExtensions)
        home.packages = with pkgs.gnomeExtensions; [
          tray-icons-reloaded
          blur-my-shell
          removable-drive-menu
          just-perfection
          caffeine
          clipboard-indicator
          bluetooth-quick-connect
          gsconnect
          pip-on-top
          forge
          dash-to-dock
          native-window-placement
        ];
      };
    };
  };
}
