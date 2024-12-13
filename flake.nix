{
  description = "Build NixOS images for various ARM single computer boards";
  # pin this to unstable
  inputs.nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixpkgs-unstable";

  outputs = { nixpkgs, ... }: {
    packages.x86_64-linux = import ./. {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    };
  };
}
