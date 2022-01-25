{
  description = "Build NixOS images for various ARM single computer boards";
  # pin this to unstable
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          aarch64imgs = pkgs.callPackage ./. { };
        in {
          inherit (aarch64imgs)
            aarch64Image rock64 rockPro64 roc-pc-rk3399 pinebookPro;
        });
    };
}
