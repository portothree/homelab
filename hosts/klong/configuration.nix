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
    networkmanager = {
      enable = true;
      plugins = with pkgs; [ networkmanager-openvpn ];
    };
  };
  environment = {
    systemPackages = with pkgs; [ wget curl xsecurelock ];
    variables = { EDITOR = "nvim"; };
    pathsToLink = [ "/share/icons" "/share/mime" "/share/zsh" ];
  };
  services = {
    intune.enable = true;
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

