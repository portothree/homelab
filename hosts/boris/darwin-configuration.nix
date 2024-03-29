{ config, pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [ git ];
    darwinConfig =
      "$HOME/www/portothree/homelab/hosts/boris/darwin-configuration.nix";
  };
  users.users.gustavoporto = {
    name = "gustavoporto";
    home = "/Users/gustavoporto";
  };
  homebrew = {
    enable = true;
    global = { lockfiles = true; };
    brews = [ "pyqt@6" "syncthing" "python@3.10" ];
    casks = [
      "ddpm"
      "docker"
      "google-chrome"
      "anki"
      "trader-workstation"
      "stats"
      "hammerspoon"
    ];
    masApps = { "tailscale" = 1475387142; };
  };
  fonts = {
    fontDir = { enable = true; };
    fonts = with pkgs; [ fira-code ];
  };
  services = {
    nix-daemon = { enable = true; };
    karabiner-elements = { enable = false; };
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  system.stateVersion = 4;
}
