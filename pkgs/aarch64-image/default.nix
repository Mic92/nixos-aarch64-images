{ stdenv, fetchurl, zstd }:
let
  src = (fetchurl {
    # unfortunally there is no easy way right now to reproduce the same evaluation
    # as hydra, since `pkgs.path` is embedded in the binary
    # To get a new url use:
    # $ curl -s -L -I -o /dev/null -w '%{url_effective}' "https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image_new_kernel_no_zfs.aarch64-linux/latest/download/1"
    url = "https://hydra.nixos.org/build/282058919/download/1/nixos-sd-image-25.05beta720697.5d67ea6b4b63-aarch64-linux.img.zst";
    sha256 = "5827626d41174efca81b045ab1b7273c70b9dc41dd8cc997ba266819d904ce30";
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
