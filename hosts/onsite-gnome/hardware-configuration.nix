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

    boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usbhid" "usb_storage" "sd_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/40c6a2ad-2559-4559-985c-64bd930c70be";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/FD28-26EC";
        fsType = "vfat";
      };

  fileSystems."/mnt/ubuntu" =
    { device = "/dev/disk/by-uuid/"; #todo
      fsType = "ext4";
    };

  fileSystems."/mnt/hypr" =
    { device = "/dev/disk/by-uuid/"; #todo
      fsType = "ext4";
    };

  swapDevices = [ ];

  networking = with host; {
    useDHCP = false;                        # Deprecated
    hostName = hostName;
    networkmanager.enable = true;
    interfaces = {
      lo = {
        useDHCP = true;                     # For versatility sake, manually edit IP on nm-applet.
        #ipv4.addresses = [ {
        #    address = "192.168.0.51";
        #    prefixLength = 24;
        #} ];
      };
      wlp0s20f3 = {
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
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
