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
        name = "Dracula";
#        name = "Yaru-Dark";
        name = "Cat-Gtk-Mocha-Mauve-Dark";
#        package = pkgs.dracula-theme;
        package = pkgs.catppuccin-gtk.override {
          accents = ["mauve"];
          tweaks = [ "rimless" "black" "float" ];
          size = "compact";
          variant = "mocha";
#        };
      };
      iconTheme = {
#        name = "Papirus-Dark";
#        package = pkgs.papirus-icon-theme;
        name = "Cat-Papirus-Mocha-Mauve-Dark";
       package = pkgs.catppuccin-papirus-folders.override {
           flavor = "mocha";
           accent = "mauve";
         };
      };
      font = {
        name = "Ubuntu";
      };
    };
  };
  };
}
