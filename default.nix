{ pkgs ? import <nixpkgs> {} }:

let
  aarch64Pkgs = import pkgs.path {
    system = "aarch64-linux";
  };

  buildImage = pkgs.callPackage ./pkgs/build-image {};
  aarch64Image = pkgs.callPackage ./pkgs/aarch64-image {};
in {
  inherit aarch64Image aarch64Pkgs;

  rock64 = pkgs.callPackage ./images/rock64.nix {
    inherit (aarch64Pkgs) ubootRock64;
    inherit aarch64Image buildImage;
  };
}
