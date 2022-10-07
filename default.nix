{ pkgs ? import <nixpkgs> {} }:

let
  aarch64Pkgs = pkgs.pkgsCross.aarch64-multiplatform;

  buildImage = pkgs.callPackage ./pkgs/build-image {};
  aarch64Image = pkgs.callPackage ./pkgs/aarch64-image {};
  rockchip = uboot: pkgs.callPackage ./images/rockchip.nix {
    inherit uboot;
    inherit aarch64Image buildImage;
  };
in {
  inherit aarch64Image;

  rock64 = rockchip aarch64Pkgs.ubootRock64;
  rockPro64 = rockchip aarch64Pkgs.ubootRockPro64;
  roc-pc-rk3399 = rockchip aarch64Pkgs.ubootROCPCRK3399;
  pinebookPro = rockchip aarch64Pkgs.ubootPinebookPro;
}
