#
#  Hyprland Configuration
#  Enable with "hyprland.enable = true;"
#

{ config, lib, system, pkgs, hyprland, vars, host, ... }:

let
  colors = import ../theming/colors.nix;
in
with lib;
with host;
{
  options = {
    hyprland = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkIf (config.hyprland.enable) {
    wlwm.enable = true;                       # Wayland Window Manager

    environment =
    let
      exec = "exec dbus-launch Hyprland";
    in
    {
      loginShellInit = ''
        if [ -z $DISPLAY ] && [ "$(tty)" = "/dev/tty1" ]; then
          ${exec}
        fi
      '';                                     # Start from TTY1

      variables = {
        #WLR_NO_HARDWARE_CURSORS="1";         # Needed for VM
        #WLR_RENDERER_ALLOW_SOFTWARE="1";
        XDG_CURRENT_DESKTOP="Hyprland";
        XDG_SESSION_TYPE="wayland";
        XDG_SESSION_DESKTOP="Hyprland";
      };
      sessionVariables = if hostName == "work" then {
        #GBM_BACKEND = "nvidia-drm";
        #__GL_GSYNC_ALLOWED = "0";
        #__GL_VRR_ALLOWED = "0";
        #WLR_DRM_NO_ATOMIC = "1";
        #__GLX_VENDOR_LIBRARY_NAME = "nvidia";
        #_JAVA_AWT_WM_NONREPARENTING = "1";

        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

        GDK_BACKEND = "wayland";
        WLR_NO_HARDWARE_CURSORS = "1";
        MOZ_ENABLE_WAYLAND = "1";
      } else {
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

        GDK_BACKEND = "wayland";
        WLR_NO_HARDWARE_CURSORS = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };
      systemPackages = with pkgs; [
        grimblast       # Screenshot
        light           # Brightness Control
        pamixer         # Volume Control
        swayidle        # Idle Daemon
        swaylock-effects# Lock Screen
        wl-clipboard    # Clipboard
        wlr-randr       # Monitor Settings
        xfce.thunar     # File Manager
        xorg.xrandr     # Monitor Settings
        xwayland        # X session
      ];
    };

    security.pam.services.swaylock = {
#      text = ''
#               auth sufficient pam_unix.so try_first_pass likeauth nullok
#               auth sufficient pam_fprintd.so
#               auth include login
#      '';
    };

    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --time-format '%I:%M %p | %a • %h | %F' --cmd Hyprland";
        };
      };
      vt = 7;
    };

    programs = {
      hyprland = {                            # Window Manager
        enable = true;
        package = hyprland.packages.${pkgs.system}.hyprland;
      };
    };

    systemd.sleep.extraConfig = ''
      AllowSuspend=yes
      AllowHibernation=no
      AllowSuspendThenHibernate=no
      AllowHybridSleep=yes
    '';                                       # Clamshell Mode

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };                                        # Cache

    home-manager.users.${vars.user} =
    let
      touchpad =
        if hostName == "libelula" || hostName == "oldie" || hostName == "laptop" || hostName == "work" then ''
            touchpad {
              natural_scroll=true
              scroll_factor=0.2
              middle_button_emulation=true
              tap-to-click=true
            }
          }
          '' else "";
      gestures = ''
          gestures {
            workspace_swipe=true
            workspace_swipe_fingers=3
            workspace_swipe_distance=100
          }
          '';
      workspaces =
      if secondMonitor != "" && thirdMonitor != ""
        then
              ''
                monitor=${toString mainMonitor},1920x1080@60,0x0,1
                monitor=${toString secondMonitor},1920x1200@60,1920x0,1
                monitor=${toString thirdMonitor},1920x1200@60,3840x0,1
              ''
      else if secondMonitor != "" && thirdMonitor == ""
        then ''
            monitor=${toString mainMonitor},1920x1080@60,1920x0,1
            monitor=${toString secondMonitor},1920x1080@60,0x0,1
        ''
        else
        ''
            monitor=${toString mainMonitor},1920x1080@60,1920x0,1
        ''
        ;
      monitors =
        if hostName == "desktop" || (hostName == "libelula" && secondMonitor != "") then ''
          workspace=${toString mainMonitor},1
          workspace=${toString mainMonitor},2
          workspace=${toString mainMonitor},3
          workspace=${toString mainMonitor},4
          workspace=${toString secondMonitor},5
          workspace=${toString secondMonitor},6
          workspace=${toString secondMonitor},7
          workspace=${toString secondMonitor},8
        '' else if hostName == "work" || hostName == "onsite-gnome" then ''
          workspace=${toString mainMonitor},1
          workspace=${toString secondMonitor},2
          workspace=${toString thirdMonitor},3

          bindl=,switch:Lid Switch,exec,$HOME/.config/hypr/script/clamshell.sh
        '' else ''
                          workspace=${toString mainMonitor},1
                          workspace=${toString mainMonitor},2
                          workspace=${toString mainMonitor},3
                          workspace=${toString mainMonitor},4
                          workspace=${toString mainMonitor},5
                          workspace=${toString mainMonitor},6
                          workspace=${toString mainMonitor},7
                          workspace=${toString mainMonitor},8
                          bindl=,switch:Lid Switch,exec,$HOME/.config/hypr/script/clamshell.sh
                        '';
      execute =
        if hostName == "desktop" || hostName == "beelink" then ''
          exec-once=${pkgs.swayidle}/bin/swayidle -w timeout 600 '${pkgs.swaylock}/bin/swaylock -f' timeout 1200 '${pkgs.systemd}/bin/systemctl suspend' after-resume '${config.programs.hyprland.package}/bin/hyprctl dispatch dpms on' before-sleep '${pkgs.swaylock}/bin/swaylock -f && ${config.programs.hyprland.package}/bin/hyprctl dispatch dpms off'
        '' else if hostName == "work" then ''
          exec-once=${pkgs.networkmanagerapplet}/bin/nm-applet --indicator
          #exec-once=${pkgs.google-drive-ocamlfuse}/bin/google-drive-ocamlfuse /GDrive
          exec-once=${pkgs.rclone}/bin/rclone mount --daemon gdrive: /GDrive
          exec-once=${pkgs.swayidle}/bin/swayidle -w timeout 60 '${pkgs.swaylock}/bin/swaylock -f' timeout 600 '${pkgs.systemd}/bin/systemctl suspend' after-resume '${config.programs.hyprland.package}/bin/hyprctl dispatch dpms on' before-sleep '${pkgs.swaylock}/bin/swaylock -f && ${config.programs.hyprland.package}/bin/hyprctl dispatch dpms off'
        '' else ''
          exec-once=${pkgs.networkmanagerapplet}/bin/nm-applet --indicator
          exec-once=${pkgs.swayidle}/bin/swayidle -w timeout 600 '${pkgs.swaylock}/bin/swaylock -f' timeout 1200 '${pkgs.systemd}/bin/systemctl suspend' after-resume '${config.programs.hyprland.package}/bin/hyprctl dispatch dpms on' before-sleep '${pkgs.swaylock}/bin/swaylock -f && ${config.programs.hyprland.package}/bin/hyprctl dispatch dpms off'
           '';
    in
    let
swaylockConf=''
ignore-empty-password
daemonize
indicator
clock
screenshots

effect-blur=11x11
effect-compose=1110,-170;40%x-1;${vars.location}/modules/theming/rani.png
effect-compose=120,-100;${vars.location}/modules/theming/warrior.png
font=JetBrains Mono
indicator-radius=80
indicator-thickness=8
timestr=%I:%M %p
datestr=%F

inside-color=#181926
ring-color=#8bd5ca
key-hl-color=#a6da95
text-color=#cad3f5
layout-text-color=#cad3f5
layout-bg-color=#181926
text-caps-lock-color=#cad3f5

inside-clear-color=#f4dbd6
ring-clear-color=#f0c6c6
text-clear-color=#1e2030

inside-ver-color=#91d7e3
ring-ver-color=#7dc4e4
text-ver-color=#1e2030

inside-wrong-color=#ee99a0
ring-wrong-color=#ed8796
text-wrong-color=#1e2030
'';
macchiato= ''
$rosewater = 0xfff4dbd6
$flamingo  = 0xfff0c6c6
$pink      = 0xfff5bde6
$mauve     = 0xffc6a0f6
$red       = 0xffed8796
$maroon    = 0xffee99a0
$peach     = 0xfff5a97f
$green     = 0xffa6da95
$teal      = 0xff8bd5ca
$sky       = 0xff91d7e3
$sapphire  = 0xff7dc4e4
$blue      = 0xff8aadf4
$lavender  = 0xffb7bdf8

$text      = 0xffcad3f5
$subtext1  = 0xffb8c0e0
$subtext0  = 0xffa5adcb

$overlay2  = 0xff939ab7s
$overlay1  = 0xff8087a2
$overlay0  = 0xff6e738d

$surface2  = 0xff5b6078
$surface1  = 0xff494d64
$surface0  = 0xff363a4f

$base      = 0xff24273a
$mantle    = 0xff1e2030
$crust     = 0xff181926
'';

hyprlandConf = ''
        ${workspaces}
        ${monitors}
        monitor=,highres,auto,auto

        general {
          #main_mod=SUPER
          border_size=3
          gaps_in=5
          gaps_out=7
          col.active_border=0x80ffffff
          col.inactive_border=0x66333333
          layout=dwindle
        }

        decoration {
          rounding=5
          active_opacity=0.93
          inactive_opacity=0.93
          fullscreen_opacity=1
          blur {
            enabled=true
          }
          drop_shadow=false
        }

        animations {
          enabled = true
          bezier = overshot, 0.05, 0.9, 0.1, 1.05
          bezier = smoothOut, 0.5, 0, 0.99, 0.99
          bezier = smoothIn, 0.5, -0.5, 0.68, 1.5
          bezier = rotate,0,0,1,1
          animation = windows, 1, 4, overshot, slide
          animation = windowsIn, 1, 2, smoothOut
          animation = windowsOut, 1, 0.5, smoothOut
          animation = windowsMove, 1, 3, smoothIn, slide
          animation = border, 1, 5, default
          animation = fade, 1, 4, smoothIn
          animation = fadeDim, 1, 4, smoothIn
          animation = workspaces, 1, 4, default
          animation = borderangle, 1, 20, rotate, loop
        }

        input {
          kb_layout=ch
          #kb_options=caps:ctrl_modifier
          follow_mouse=2
          repeat_delay=250
          numlock_by_default=1
          accel_profile=flat
          sensitivity=0.8
          ${touchpad}
        }

        ${gestures}

        dwindle {
          pseudotile=false
          force_split=2
        }

        misc {
          disable_hyprland_logo=true
          disable_splash_rendering=true
          mouse_move_enables_dpms=true
          key_press_enables_dpms=true
        }

        debug {
          damage_tracking=2
        }

#bind = SUPER SHIFT, N, exec, dunstctl set-paused toggle
#bind = SUPER SHIFT, Y, exec, fish -c bluetooth_toggle
#bind = SUPER SHIFT, W, exec, fish -c wifi_toggle
#
#bind = SUPER, bracketright, exec, playerctl next
#bind = SUPER, bracketleft, exec, playerctl previous
#
#bind = , XF86AudioRaiseVolume, exec, volumectl -u up
#bind = , XF86AudioLowerVolume, exec, volumectl -u down
#bind = , XF86AudioMute, exec, volumectl toggle-mute
#bind = , XF86AudioMicMute, exec, volumectl -m toggle-mute
#
#bind = , XF86MonBrightnessUp, exec, lightctl up
#bind = , XF86MonBrightnessDown, exec, lightctl down




bindm=SUPER,mouse:272,movewindow
bindm=SUPER,mouse:273,resizewindow

bind=SUPER,Return,exec, kitty
bind=SUPER,Q,killactive,
bind=ALT,F,killactive,
#bind=SUPER,Escape,exit,
#bind=SUPER,S,exec,systemctl suspend
bind=SUPER,L,exec,swaylock
bind=SUPER,E,exec,thunar
bind=SUPER,H,togglefloating,
bind=SUPER,Space,exec,pkill wofi || ${pkgs.wofi}/bin/wofi --show drun
bindr=SUPER,SUPER_L,exec,pkill wofi || ${pkgs.wofi}/bin/wofi --show drun
bind=SUPER,P,pseudo,
bind=SUPER,F,fullscreen,
bind=SUPER,R,forcerendererreload
bind=SUPERSHIFT,R,exec,hyprctl reload
bind=SUPER,T,exec,kitty



bind=SUPER,left,movefocus,l
bind=SUPER,right,movefocus,r
bind=SUPER,up,movefocus,u
bind=SUPER,down,movefocus,d
bind=SUPER, Tab, cyclenext,
bind=SUPER, Tab, bringactivetotop,
#bind = SUPER, Tab, exec, pypr toggle_minimized

bind = CTRL ALT SHIFT, 1, movetoworkspace, 1
bind = CTRL ALT SHIFT, 2, movetoworkspace, 2
bind = CTRL ALT SHIFT, 3, movetoworkspace, 3
bind = CTRL ALT SHIFT, 4, movetoworkspace, 4
bind = CTRL ALT SHIFT, 5, movetoworkspace, 5
bind = CTRL ALT SHIFT, 6, movetoworkspace, 6
bind = CTRL ALT SHIFT, 7, movetoworkspace, 7
bind = CTRL ALT SHIFT, 8, movetoworkspace, 8
bind = CTRL ALT SHIFT, 9, movetoworkspace, 9
bind = CTRL ALT SHIFT, 0, movetoworkspace, 10


bind = CTRL ALT, 1, movetoworkspacesilent, 1
bind = CTRL ALT, 2, movetoworkspacesilent, 2
bind = CTRL ALT, 3, movetoworkspacesilent, 3
bind = CTRL ALT, 4, movetoworkspacesilent, 4
bind = CTRL ALT, 5, movetoworkspacesilent, 5
bind = CTRL ALT, 6, movetoworkspacesilent, 6
bind = CTRL ALT, 7, movetoworkspacesilent, 7
bind = CTRL ALT, 8, movetoworkspacesilent, 8
bind = CTRL ALT, 9, movetoworkspacesilent, 9
bind = CTRL ALT, 0, movetoworkspacesilent, 10

bind=SUPERSHIFT,left,movewindow,l
bind=SUPERSHIFT,right,movewindow,r
bind=SUPERSHIFT,up,movewindow,u
bind=SUPERSHIFT,down,movewindow,d

bind=CTRLALT,right,workspace,+1
bind=CTRLALT,left,workspace,-1

bind=CTRLALT SHIFT,right,movetoworkspace,+1
bind=CTRLALT SHIFT,left,movetoworkspace,-1

#bind=CTRL,right,resizeactive,20 0
#bind=CTRL,left,resizeactive,-20 0
#bind=CTRL,up,resizeactive,0 -20
#bind=CTRL,down,resizeactive,0 20c

bind=SUPER,M,submap,resize
submap=resize
binde=,right,resizeactive,20 0
binde=,left,resizeactive,-20 0
binde=,up,resizeactive,0 -20
binde=,down,resizeactive,0 20
bind=,escape,submap,reset
submap=reset

bind = SUPER, S, exec, spotify
bind = SUPER, Z, exec, pypr zoom
bind = SUPER, ESCAPE, exec, fish -c wlogout_uniqe

        #bind=CTRL,right,resizeactive,20 0
        #bind=CTRL,left,resizeactive,-20 0
        #bind=CTRL,up,resizeactive,0 -20
        #bind=CTRL,down,resizeactive,0 20

#        bind=SUPER,M,submap,resize
#        submap=resize
#        binde=,right,resizeactive,20 0
#        binde=,left,resizeactive,-20 0
#        binde=,up,resizeactive,0 -20
#        binde=,down,resizeactive,0 20
#        bind=,escape,submap,reset
#        submap=reset
#
#        bind=SUPER,Z,layoutmsg,togglesplit

        bind=,print,exec,${pkgs.grimblast}/bin/grimblast --notify --freeze --wait 1 copysave area ~/Pictures/$(date +%Y-%m-%dT%H%M%S).png
        bind=,XF86AudioLowerVolume,exec,${pkgs.pamixer}/bin/pamixer -d 10
        bind=,XF86AudioRaiseVolume,exec,${pkgs.pamixer}/bin/pamixer -i 10
        bind=,XF86AudioMute,exec,${pkgs.pamixer}/bin/pamixer -t
        bind=SUPER_L,c,exec,${pkgs.pamixer}/bin/pamixer --default-source -t
        bind=CTRL,F10,exec,${pkgs.pamixer}/bin/pamixer -t
        bind=,XF86AudioMicMute,exec,${pkgs.pamixer}/bin/pamixer --default-source -t
        bind=,XF86MonBrightnessDown,exec,${pkgs.light}/bin/light -U 10
        bind=,XF86MonBrightnessUP,exec,${pkgs.light}/bin/light -A 10

        windowrulev2=float,title:^(Volume Control)$
        windowrulev2 = keepaspectratio,class:^(firefox)$,title:^(Picture-in-Picture)$
        windowrulev2 = noborder,class:^(firefox)$,title:^(Picture-in-Picture)$
        windowrulev2 = float, title:^(Picture-in-Picture)$
        windowrulev2 = size 24% 24%, title:(Picture-in-Picture)
        windowrulev2 = move 75% 75%, title:(Picture-in-Picture)
        windowrulev2 = pin, title:^(Picture-in-Picture)$
        windowrulev2 = float, title:^(Firefox)$
        windowrulev2 = size 24% 24%, title:(Firefox)
        windowrulev2 = move 74% 74%, title:(Firefox)
        windowrulev2 = pin, title:^(Firefox)$

        exec-once=dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        exec-once=${pkgs.waybar}/bin/waybar
        exec-once=${pkgs.eww-wayland}/bin/eww daemon
        #exec-once=$HOME/.config/eww/scripts/eww        # When running eww as a bar
        exec-once=${pkgs.blueman}/bin/blueman-applet
        exec-once=${pkgs.swaynotificationcenter}/bin/swaync
        ${execute}
      '';
    in
    {
      xdg.configFile."hypr/hyprland.conf".text = hyprlandConf;
#      xdg.configFile."hypr/macchiato.conf".text = macchiato;
#
      xdg.configFile."swaylock/config".text = swaylockConf;
      programs.swaylock.settings = {
#ignore-empty-password
#daemonize
#indicator
#clock
#screenshots
#          ignore-empty-password = "true";
#          daemonize = "true";
#          indicator = "true";
#          clock = "true";
#          screenshots = "true";
#
#          effect-blur = "11x11";
#          effect-compose = "1110,-170;40%x-1;${vars.location}/hosts/hypr-oldie/home-configs-to-copy/.config/swaylock/rani.png";
#          effect-compose = "120,-100;${vars.location}/hosts/hypr-oldie/home-configs-to-copy/.config/swaylock/warrior.png";
#          effect-compose = "120,-100;${vars.location}/hosts/hypr-oldie/home-configs-to-copy/.config/swaylock/warrior.png";
#          font = "JetBrains Mono";
          indicator-radius = 50;
          indicator-thickness = 1;
#          timestr = "%I:%M %p";
#          datestr = "%F";
#
#          inside-color = "181926";
#          ring-color = "8bd5ca";
#          key-hl-color = "a6da95";
#          text-color = "cad3f5";
#          layout-text-color = "cad3f5";
#          layout-bg-color = "181926";
#          text-caps-lock-color = "cad3f5";
#
#          inside-clear-color = "f4dbd6";
#          ring-clear-color = "f0c6c6";
#          text-clear-color = "1e2030";
#
#          inside-ver-color = "91d7e3";
#          ring-ver-color = "7dc4e4";
#          text-ver-color = "1e2030";
#
#          inside-wrong-color = "ee99a0";
#          ring-wrong-color = "ed8796";
#          text-wrong-color = "1e2030";
      };
      home.file = {
        ".config/hypr/script/clamshell.sh" = {
          text = ''
            #!/bin/sh

            if grep open /proc/acpi/button/lid/LID/state; then
              ${config.programs.hyprland.package}/bin/hyprctl keyword monitor "${toString mainMonitor}, 1920x1080, 0x0, 1"
            else
              if [[ `hyprctl monitors | grep "Monitor" | wc -l` != 1 ]]; then
                ${config.programs.hyprland.package}/bin/hyprctl keyword monitor "${toString mainMonitor}, disable"
              else
                ${pkgs.swaylock}/bin/swaylock -f
                ${pkgs.systemd}/bin/systemctl suspend
              fi
            fi
          '';
          executable = true;
        };
      };
    };
  };
}
