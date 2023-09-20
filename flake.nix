{
  description = "@portothree homelab";
  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
      "https://cache.nixos.org"
      "https://portothree.cachix.org"
      "https://microvm.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "portothree.cachix.org-1:L4w3V/jrM+5cG0yEAypCPan94GLUxWYm8VFLB774J6I="
      "microvm.cachix.org-1:oXnBc6hRE3eX5rSYdRyMYXnfzcCxC7yKPTbZXALsqys="
    ];
  };
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-intune.follows = "nixpkgs";
    intune-patch = {
      url =
        "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/221628.patch";
      flake = false;
    };
    flake-utils-plus.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nixos-hardware.url = "github:NixOs/nixos-hardware/master";
    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; };
    k1x = { url = "github:p8sco/k1x"; };
    devenv = { url = "github:cachix/devenv/v0.5"; };
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-intune, intune-patch
    , flake-utils-plus, nixos-hardware, microvm, pre-commit-hooks, k1x, devenv
    , ... }@inputs:
    let system = "x86_64-linux";
    in flake-utils-plus.lib.mkFlake {
      inherit self inputs;
      channelsConfig = { allowUnfree = true; };
      channels.nixpkgs-intune.patches = [
        #intune-patch
        ./intune.patch
      ];
      outputsBuilder = channels: {
        packages.${system} = {
          k1x = k1x.packages.${system}.default;
          inherit (devenv.packages.${system}.devenv)
          ;
        };
      };
      hosts = {
        klong = {
          inherit system;
          channelName = "nixpkgs-intune";
          modules = [
            { networking = { hostName = "klong"; }; }
            ./hosts/klong/configuration.nix
          ];
        };
        jorel = {
          inherit system;
          channelName = "nixpkgs-intune";
          modules = [
            { networking = { hostName = "jorel"; }; }
            ./hosts/jorel/configuration.nix
            nixos-hardware.nixosModules.common-cpu-amd
            microvm.nixosModules.host
          ];
        };
        oraculo = {
          channelName = "nixpkgs";
          modules = [
            microvm.nixosModules.microvm
            {
              networking = { hostName = "oraculo"; };
              microvm = {
                hypervisor = "qemu";
                interfaces = [{
                  type = "user";
                  id = "microvm-a1";
                  mac = "02:00:00:00:00:01";
                }];
              };
            }
            ({ config, pkgs, ... }: {
              system.stateVersion = config.system.nixos.version;
              users = { users = { root = { password = ""; }; }; };
              services = {
                getty.helpLine = ''
                  Log in as "root" with an empty password.
                  Type Ctrl-a c to switch to the qemu console
                  and `quit` to stop the VM.
                '';
              };
              nix = {
                enable = true;
                package = pkgs.nixFlakes;
                extraOptions = ''
                  experimental-features = nix-command flakes
                '';
                registry = { nixpkgs.flake = nixpkgs; };
              };
            })
          ];
        };
      };
      checks.${system}.pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt = {
            enable = true;
            excludes = [ "hardware-configuration.nix" ];
          };
          shellcheck = { enable = true; };
        };
      };
    };
}
