#
# Hardware settings for HP ProBook 650 G1 15.6" Laptop
# Dual boot active. Windows @ sda4 / NixOS @ sda5
#
# flake.nix
#  └─ ./hosts
#      └─ ./laptop
#          ├─ default.nix
#          └─ hardware-configuration.nix *
#
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
#

{ config, lib, pkgs, modulesPath, host, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/18fd3508-94a9-4d44-8b18-d7971fbb86c5";
      fsType = "ext4";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with networking.interfaces.<interface>.useDHCP.

  networking = with host; {
      useDHCP = false;                        # Deprecated
      hostName = hostName;
      networkmanager.enable = true;
      interfaces = {
        enp4s0f1 = {
          useDHCP = true;                     # For versatility sake, manually edit IP on nm-applet.
          #ipv4.addresses = [ {
          #    address = "192.168.0.51";
          #    prefixLength = 24;
          #} ];
        };
        wlp3s0 = {
          useDHCP = true;
          #ipv4.addresses = [ {
          #  address = "192.168.0.51";
          #  prefixLength = 24;
          #} ];
        };
      };
  #    defaultGateway = "192.168.0.1";
  #    nameservers = [ "192.168.0.4" ];
      firewall = {
        enable = false;
        #allowedUDPPorts = [ 53 67 ];
        #allowedTCPPorts = [ 53 80 443 9443 ];
      };
    };

  # networking.interfaces.enp4s0f1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}