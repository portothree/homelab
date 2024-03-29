{ config, pkgs, ... }:

{
  imports = [ ../common.nix ./hardware-configuration.nix ];
  boot = {
    loader = {
	systemd-boot = {
		enable = true;
	};
	efi = {
		canTouchEfiVariables = true;
	};
    };
  };
  networking = {
    hostName = "lara";
    useDHCP = false;
    interfaces = { ens18 = { useDHCP = true; }; };
    extraHosts = ''
      192.168.1.100 pve
    '';
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    firewall = {
      allowedTCPPorts = [ 22 53 80 6443 ];
      allowedUDPPorts = [ 53 ];
    };
  };
  services = {
    openssh = { enable = true; };
    k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [ 
        "--disable traefik"
        "--disable servicelb"
      ];
    };
  };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    };
  };
  environment = { systemPackages = with pkgs; [ git curl k3s k9s kubectl fluxcd fluxctl ]; };
  system = { stateVersion = "21.11"; };
}
