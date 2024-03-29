{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ../common.nix ../../modules ];
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
      grub = {
        efiSupport = true;
        device = "nodev";
      };
    };
  };
  networking = {
    useDHCP = false;
    interfaces = { wlp0s20f3 = { useDHCP = true; }; };
    nameservers = [ "100.100.100.100" ];
    search = [ "tailea386.ts.net" ];
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      trustedInterfaces = [ "tailscale0" ];
      checkReversePath = false;
    };
    wireless = {
      enable = true;
      userControlled.enable = true;
      environmentFile = "/etc/nixos/.env";
      networks = {
        "@WIRELESS_SSID_HOME@" = {
          psk = "@WIRELESS_PSK_HOME@";
          extraConfig =
            "bssid=@WIRELESS_BSSID_HOME@,freq_list=@WIRELESS_FREQ_HOME@";
        };
        "@WIRELESS_SSID_PHONE_HOTSPOT@" = {
          psk = "@WIRELESS_PSK_PHONE_HOTSPOT@";
        };
        "@WIRELESS_SSID_OFFICE@" = { psk = "@WIRELESS_PSK_OFFICE@"; };
      };
    };
  };
  environment = {
    systemPackages = with pkgs; [ wget curl xsecurelock tailscale ];
    variables = { EDITOR = "nvim"; };
    pathsToLink = [ "/share/icons" "/share/mime" "/share/zsh" ];
  };
  services = {
    openssh.enable = true;
    udev = { packages = with pkgs; [ ledger-udev-rules ]; };
    xserver = {
      enable = true;
      layout = "us";
      libinput = {
        enable = true;
        mouse = { accelProfile = "flat"; };
        touchpad = { accelProfile = "flat"; };
      };
      displayManager = { startx = { enable = true; }; };
    };
    tailscale.enable = true;
    blueman.enable = true;
  };
  sound.enable = true;
  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };
    bluetooth.enable = true;
  };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" "docker" ];
        shell = pkgs.zsh;
      };
    };
  };
  virtualisation = { docker = { enable = true; }; };
  fonts.fonts = with pkgs; [ fira-code siji ];
  nix = {
    enable = true;
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = { trusted-users = [ "root" "porto" ]; };
  };
  system.stateVersion = "22.05";
}

