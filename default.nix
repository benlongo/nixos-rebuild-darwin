let pkgs = import <nixpkgs> {};
in pkgs.callPackage ./nixos-rebuild.nix {}
