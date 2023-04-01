{ stdenv, fetchurl, zstd }:

stdenv.mkDerivation {
  name = "aarch64-image";
  src = fetchurl {
    # unfortunally there is no easy way right now to reproduce the same evaluation
    # as hydra, since `pkgs.path` is embedded in the binary
    # To get a new url use:
    # $ curl -s -L -I -o /dev/null -w '%{url_effective}' "https://hydra.nixos.org/job/nixos/release-20.03/nixos.sd_image.aarch64-linux/latest/download/1"
    url = "https://hydra.nixos.org/build/214526899/download/1/nixos-sd-image-22.11.3408.a575c243c23-aarch64-linux.img.zst";
    sha256 = "sha256-lYTksexy1Z9RJKtdZO1ufutLCPV4FmFVpF2alFMETEg=";
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

  nativeBuildInputs = [
    zstd
  ];

  installPhase = ''
    zstdcat $src > $out
  '';
}
