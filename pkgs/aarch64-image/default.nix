{ stdenv, fetchurl, zstd }:
let
  src = (fetchurl {
    # unfortunally there is no easy way right now to reproduce the same evaluation
    # as hydra, since `pkgs.path` is embedded in the binary
    # To get a new url use:
    # $ curl -s -L -I -o /dev/null -w '%{url_effective}' "https://hydra.nixos.org/job/nixos/release-20.03/nixos.sd_image.aarch64-linux/latest/download/1"
    url = "https://hydra.nixos.org/build/269682674/download/1/nixos-sd-image-24.05.3914.c3d4ac725177-aarch64-linux.img.zst";
    sha256 = "0g11hpsl8sw44vi7f6pmhxi1x59v61mj2vcpv5cz3j98r58w13y6";
  }).overrideAttrs (final: prev: {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  });
in
stdenv.mkDerivation {
  name = "aarch64-image";
  inherit src;
  preferLocalBuild = true;
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  # Performance
  dontPatchELF = true;
  dontStrip = true;
  noAuditTmpdir = true;
  dontPatchShebangs = true;

  nativeBuildInputs = [
    zstd
  ];

  installPhase = ''
    zstdcat $src > $out
  '';
}
