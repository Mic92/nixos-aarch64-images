{ lib, ... }:
let
  partitionOptions = lib.types.submodule ({ config, ... }: {
    options = {
      name = lib.mkOption {
        default = config._module.args.name;
        type = lib.types.nullOr lib.types.str;
        description = ''
          Name of the partition
        '';
      };

      start = lib.mkOption {
        default = null;
        type = lib.types.int;
        description = ''
          Start of the partition in sectors (512 byte)
        '';
      };

      size = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.int;
        description = ''
          Size of the partition in sectors (512 byte).
          Can be larger than the source image.
        '';
      };

      source = lib.mkOption {
        default = null;
        type = lib.types.path;
        description = ''
          Source file that will be copied to partition
        '';
      };

      attrs = lib.mkOption {
        default = null;
        example = "LegacyBIOSBootable";
        type = lib.types.nullOr lib.types.str;
        description = ''
          Additional partition to
        '';
      };

      type = lib.mkOption {
        default = "0FC63DAF-8483-4772-8E79-3D69D8477DE4";
        type = lib.types.str;
        description = ''
          Partition type. Defaults to `Linux filesystem`
        '';
      };

      useBootPartition = lib.mkOption {
        default = false;
        type = lib.types.bool;
        description = ''
          Additional partition to
        '';
      };
    };
  });
in {
  options = {
    format = lib.mkOption {
      default = "gpt";
      type = lib.types.enum [ "gpt" "mbr" ];
      description = ''
        Partition format
      '';
    };

    firstLba = lib.mkOption {
      default = 64;
      type = lib.types.int;
      description = ''
        first logical block
      '';
    };

    partitions = lib.mkOption {
      default = [];
      description = ''
        Partitions to create in the image
      '';
      type = lib.types.attrsOf partitionOptions;
    };
  };
}
