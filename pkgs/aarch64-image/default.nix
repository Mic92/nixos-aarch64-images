{ stdenv, fetchurl, zstd }:

stdenv.mkDerivation {
  name = "aarch64-image";
  src = fetchurl {
    # unfortunally there is no easy way right now to reproduce the same evaluation
    # as hydra, since `pkgs.path` is embedded in the binary
    # To get a new url use:
    # $ curl -s -L -I -o /dev/null -w '%{url_effective}' "https://hydra.nixos.org/job/nixos/release-20.03/nixos.sd_image.aarch64-linux/latest/download/1"
    url = "https://hydra.nixos.org/build/253982999/download/1/nixos-sd-image-23.11.5541.56528ee42526-aarch64-linux.img.zst";
    sha256 = "0c7kqgp77433zq1710lpjwpmr06wvgx19767p9hlafa849lmq76q";
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
