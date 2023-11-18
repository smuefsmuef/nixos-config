#
#  Screenshots
#

{ config, lib, pkgs, user, vars, ... }:

{
  config = lib.mkIf (config.services.xserver.enable) {
    home-manager.users.${vars.user} = {
      services.flameshot = {
        enable = true;
        settings = {
          General = {
            savePath = "/home/${vars.user}/Desktop";
            saveAsFileExtension = ".png";
            uiColor = "#2d0096";
            showHelp = "false";
            disabledTrayIcon = "true";
          };
        };
      };
    };
  };
}
