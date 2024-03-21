#
#  GTK
#

{ pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    home = {
      file.".face".source = ./face;
      file.".config/.face".source = ./face;
      file.".config/wall.png".source = ./wall.png;
      file.".background-image".source = ./wall.png;
      file.".config/wall.mp4".source = ./wall.mp4;
      pointerCursor = {                     # System-Wide Cursor
        gtk.enable = true;
#        name = "Dracula-cursors";
        name = "Catppuccin-Mocha-Dark-Cursors";
#        package = pkgs.dracula-theme;
        package = pkgs.catppuccin-cursors.mochaDark;
        size = 16;
      };
    };

    gtk = {                                 # Theming
      enable = true;
      theme = {
#        name = "Dracula";
#        name = "Yaru-Dark";
#        name = "Catppuccin-Macchiato-Compact-Blue-Dark";
        name = "Orchis-Dark-Compact";
        package = pkgs.orchis-theme;
#        package = pkgs.yaru-theme;
#        package = pkgs.dracula-theme;
#        package = pkgs.catppuccin-gtk.override {
#          accents = ["blue"];
#          tweaks = [ "rimless" "black" ];
#          size = "compact";
#          variant = "mocha";
#        };
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
#        name = "cat-mocha-mauve";
#       package = pkgs.catppuccin-papirus-folders.override {
#           flavor = "mocha";
#           accent = "mauve";
#         };
      };
      font = {
        name = "Ubuntu";
      };
    };
  };
  programs.dconf.enable = true;
 /* nixpkgs = {
    overlays = [
      (self: super: {
        gnome = super.gnome.overrideScope' (selfg: superg: {
          gnome-shell = superg.gnome-shell.overrideAttrs (old: {
            patches = (old.patches or []) ++ [
              (pkgs.substituteAll {
                      name = "login-screen.patch";
                      url = "https://gist.githubusercontent.com/caldetas/183671dfc848c389aad53c49d356130a/raw/240fbf93aa7bd3a0b9138a7011a91f682371023a/gistfile1.txt";
                      hash = "";
              })
            ];
          });
        });
      })
    ];
  };*/

  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
  [com.ubuntu.login-screen]
  background-repeat='no-repeat'
  background-size='cover'
  background-color='#777777'
  background-picture-uri='file:///home/${vars.user}/.background-image'
  '';

}
