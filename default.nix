{ pkgs ? import <nixpkgs> {} }:

let
  aarch64Pkgs = import pkgs.path {
    system = "aarch64-linux";
  };

  buildImage = pkgs.callPackage ./pkgs/build-image {};
  aarch64Image = pkgs.callPackage ./pkgs/aarch64-image {};
  rockchip = uboot: pkgs.callPackage ./images/rockchip.nix {
    inherit uboot;
    inherit aarch64Image buildImage;
  };
in {
  inherit aarch64Image aarch64Pkgs;

  rock64 = rockchip aarch64Pkgs.ubootRock64;
}
