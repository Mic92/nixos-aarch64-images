{ stdenv, fetchurl, zstd }:
let
  src = (fetchurl {
    # this is updated by ./scripts/upload-image.sh
    url = "https://github.com/Mic92/nixos-aarch64-images/releases/download/25.05beta/nixos-sd-image-25.05beta-aarch64-linux.img.zst";
    hash = "sha256-WCdibUEXTvyoGwRasbcnPHC53EHdjMmXuiZoGdkEzjA=";
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
