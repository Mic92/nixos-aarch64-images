{ stdenv, fetchurl }:

stdenv.mkDerivation {
  name = "aarch64-image";
  src = fetchurl {
    # unfortunally there is no easy way right now to reproduce the same evaluation
    # as hydra, since `pkgs.path` is embedded in the binary
    # To get a new url use:
    # $ curl -s -L -I -o /dev/null -w '%{url_effective}' "https://hydra.nixos.org/job/nixos/release-20.03/nixos.sd_image.aarch64-linux/latest/download/1"
    url = "https://hydra.nixos.org/build/126476381/download/1/nixos-sd-image-20.03.2906.c2c55c94c19-aarch64-linux.img.bz2";
    sha256 = "sha256-dCXr90lTU/ek7XANIwo+kgAl1NA6I3mIs3HYcZfis+Q=";
  };
  preferLocalBuild = true;
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  # Performance
  dontPatchELF = true;
  dontStrip = true;
  noAuditTmpdir = true;
  dontPatchShebangs = true;

  installPhase = ''
    bzcat $src > $out
  '';
}
