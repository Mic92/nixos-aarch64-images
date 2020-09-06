{ lib
, buildImage
, uboot
, aarch64Image
, extraConfig ? {}
}:

let
  idbloaderOffset = 64; # 0x40
  ubootOffset = 16384; # 0x4000
  # at the time of writing: 461K, let's very safe security margin of 8mb
  ubootSize = 16384; # 8mb
in buildImage {
  config = {
    imports = [ extraConfig ];
    format = "gpt";
    partitions = {
      idbloader = {
        source = "${uboot}/idbloader.img";
        size = ubootOffset - idbloaderOffset;
        start = idbloaderOffset;
      };
      uboot = {
        source = "${uboot}/u-boot.itb";
        size = ubootSize;
        start = ubootOffset;
      };
      nixos = {
        source = aarch64Image;
        start = ubootOffset + ubootSize;
        attrs = "LegacyBIOSBootable";
        useBootPartition = true;
      };
    };
  };
}
