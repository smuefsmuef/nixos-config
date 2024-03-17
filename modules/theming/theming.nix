#
#  GTK
#

{ pkgs, vars, ... }:

{
  home-manager.users.${vars.user} = {
    home = {
      file.".config/wall".source = ./wall;
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
#        package = pkgs.orchis-theme;
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
    qt.enable = true;
    qt.platformTheme = "gtk";
    qt.style.name = "adwaita-dark";
    qt.style.package = pkgs.adwaita-qt;
  };
}
