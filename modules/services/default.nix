#
#  Services
#
#  flake.nix
#   ├─ ./hosts
#   │   └─ configuration.nix
#   └─ ./modules
#       └─ ./services
#           └─ default.nix *
#               └─ ...
#

[
  ./avahi.nix
  ./dunst.nix
  ./picom.nix
  ./polybar.nix
  ./surfshark.nix
  ./sxhkd.nix
  ./udiskie.nix
]

