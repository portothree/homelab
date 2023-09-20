{ config, pkgs, ... }:

{
  imports = [
    ../../modules
    ../platformio.nix
    ../zsa.nix
    ../common.nix
    ./hardware-configuration.nix
  ];
  boot = {
    loader = {
      systemd-boot = { enable = true; };
      efi = { canTouchEfiVariables = true; };
    };
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback.out ];
    kernelModules = [ "v4l2loopback" "snd-aloop" ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
    '';
  };
  fileSystems."/home" = {
    device = "/dev/pool/home";
    fsType = "ext4";
  };
  networking = {
    useDHCP = false;
    useNetworkd = true;
    interfaces = { enp34s0 = { useDHCP = true; }; };
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      trustedInterfaces = [ "tailscale0" ];
      checkReversePath = false;
    };
    nameservers = [ "100.100.100.100" ];
    search = [ "tailea386.ts.net" ];
  };
  location = {
    # Lisbon, Portugal
    latitude = 38.736946;
    longitude = -9.142685;
  };
  services = {
    intune.enable = true;
    openvpn = {
      servers = {
        vowild = { config = "config /root/nixos/openvpn/vowild.ovpn"; };
      };
    };
    clight = { enable = false; };
    openssh = {
      enable = true;
      openFirewall = false;
      settings = { PermitRootLogin = "no"; };
    };
    blueman = { enable = true; };
    udev = { packages = with pkgs; [ ledger-udev-rules android-udev-rules ]; };
    tailscale = {
      enable = true;
      port = 41641;
    };
    xserver = {
      enable = true;
      layout = "us";
      videoDrivers = [ "nvidia" ];
      displayManager = { startx = { enable = true; }; };
      screenSection = ''
        Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        Option         "AllowIndirectGLXProtocol" "off"
        Option         "TripleBuffer" "on"
      '';
    };
    openvpn = {
      servers = {
        vowild = {
          config = "config /root/nixos/openvpn/vowild.ovpn";
        };
      };
    };
  };
  systemd = {
    network = {
      enable = true;
      wait-online = { extraArgs = [ "--any" ]; };
    };
  };
  users = {
    users = {
      porto = {
        isNormalUser = true;
        extraGroups = [ "wheel" "audio" "dialout" "docker" "plugdev" ];
        shell = pkgs.zsh;
      };
    };
  };
  environment = {
    systemPackages = with pkgs; [ wget curl xsecurelock microsoft-edge ];
    variables = { EDITOR = "nvim"; };
    pathsToLink = [ "/share/icons" "/share/mime" "/share/zsh" ];
  };
  virtualisation = {
    docker = {
      enable = true;
      liveRestore = false;
    };
  };
  fonts = { fonts = with pkgs; [ fira-code siji ]; };
  sound = { enable = true; };
  hardware = {
    nvidia = { package = config.boot.kernelPackages.nvidiaPackages.stable; };
    opengl.enable = true;
    bluetooth.enable = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };
  };
  nixpkgs = {
    config = { pulseaudio = true; };
    overlays = [
      (self: super: rec {
        microsoft-edge = super.microsoft-edge.overrideAttrs
          (finalAttrs: previousAttrs: {
            postFixup = previousAttrs.postFixup + ''
              wrapProgram "$out/bin/microsoft-edge"  --add-flags --ozone-platform-hint=auto
            '';
          });
      })
    ];
  };
  nix = {
    enable = true;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = { trusted-users = [ "root" "porto" ]; };
  };
  system = {
    stateVersion = "22.05";
    copySystemConfiguration = true;
  };
}
