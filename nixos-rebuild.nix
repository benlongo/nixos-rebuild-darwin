{ pkgs, lib, ... }:
let
  fallback = import (pkgs.path + /nixos/modules/installer/tools/nix-fallback-paths.nix);
  path = pkgs.path + /pkgs/os-specific/linux/nixos-rebuild;
in
(pkgs.substituteAll {
  name = "nixos-rebuild";
  src =  path + /nixos-rebuild.sh;
  dir = "bin";
  isExecutable = true;
  inherit (pkgs) runtimeShell;
  # here is the only difference to the original definition
  nix = pkgs.nix.out;
  nix_x86_64_linux = fallback.x86_64-linux;
  nix_i686_linux = fallback.i686-linux;
  nix_aarch64_linux = fallback.aarch64-linux;
  path = lib.makeBinPath [ pkgs.coreutils pkgs.jq pkgs.gnused pkgs.gnugrep ];
}).overrideAttrs (old: {
  postInstall = ''
    # use a patched version of the target configuration's `nixos-rebuild`
    # that will work from Darwin
    substituteInPlace $out/bin/nixos-rebuild \
      --replace "--expr 'with import <nixpkgs/nixos> {}; config.system.build.nixos-rebuild'" "${./nixos-rebuild-patch.nix}"
  '';
})
