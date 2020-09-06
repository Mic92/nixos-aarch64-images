{ lib, writeText, utillinux, stdenv, python3 }:

{ config }:
let
  system = lib.evalModules {
    modules = [
      { imports = [ ./options.nix ]; }
      config
    ];
  };
  manifest = writeText "manifest.json" (builtins.toJSON system.config);
in stdenv.mkDerivation {
  name = "image";
  dontUnpack = true;
  dontInstall = true;
  # Performance
  dontPatchELF = true;
  dontStrip = true;
  noAuditTmpdir = true;
  dontPatchShebangs = true;

  nativeBuildInputs = [
    python3 utillinux
  ];
  buildPhase = ''
    runHook preBuild
    echo ${./build-image.py} ${manifest} $out
    python3 ${./build-image.py} ${manifest} $out
    runHook postBuild
  '';
}
