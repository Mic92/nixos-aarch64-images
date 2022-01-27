# NixOS aarch64 images

Build aarch64 images for ARM single board computer that require
custom uboot firmware.
It re-uses pre-build NixOS installation images,
so it can be also built on non aarch64 architectures.

## Example

```console
$ nix-build -A rock64 # for regular Rock64
$ nix-build -A rockPro64 # for RockPro64
$ sfdisk --dump result
label: gpt
label-id: 0493C426-ACD9-9843-9C4B-268C90698145
device: result
unit: sectors
first-lba: 64
last-lba: 5505943
sector-size: 512

result1 : start=          64, size=       16320, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=87A01291-DFAE-A54F-BB22-731A4A07FE78, name="idbloader"
result2 : start=       16384, size=       16384, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=34FAD60D-02BE-514E-BA65-80550BAACEF3, name="uboot"
result3 : start=       32768, size=     5473176, type=0FC63DAF-8483-4772-8E79-3D69D8477DE4, uuid=B4283CE4-FC2F-6942-A542-ABDFB5DC7668, name="nixos", attrs="LegacyBIOSBootable"
```

Built images can be than copied to sdcards etc as usual:

``` console
$ sudo dd if=./result of=/dev/mmcblk0 iflag=direct oflag=direct bs=16M status=progress
```

Replace `/dev/mmcblk0` with your actual device.

## Flakes support

Flakes support is also provided. This repository has no dependencies except for nixpkgs, however we do not provide a
lock file which means that one will be created using your system if you pull down the repo. This lets you use an
up-to-date uboot at whatever level of stability you are already comfortable with.

To build the `rockPro64` image without pulling down the repo, use:
```
nix build --no-write-lock-file 'github:Mic92/nixos-aarch64-images#rockPro64'
```

To build the `rockPro64` image without pulling down the repo and switching nixpkgs with nixpkgs-unstable:
```
nix build --no-write-lock-file --override-input nixpkgs github:nixos/nixpkgs/nixpkgs-unstable 'github:Mic92/nixos-aarch64-images#rockPro64'
```

Of course, you can replace `rockPro64` with any of the outputs included in this flake. To see the outputs, you can
invoke `nix flake show`:

```
❯ nix flake show
git+file:///home/user/git/nixos-aarch64-images
└───packages
    └───x86_64-linux
        ├───aarch64Image: package 'aarch64-image'
        ├───pinebookPro: package 'image'
        ├───roc-pc-rk3399: package 'image'
        ├───rock64: package 'image'
        └───rockPro64: package 'image'
```


## Supported boards

| Board                            | Attribute     | Status                                                                      |
| ---------------------------------|---------------| --------------------------------------------------------------------------- |
| [Rock64][]                       | rock64        | Tested & works                                                              |
| [RockPro64][]                    | rockPro64     | Tested & works (requires nixpkgs-unstable or 21.11)                         |
| [roc-pc-rk3399][]                | roc-pc-rk3399 | Untested & should work (please provide feedback)                            |
| [PinebookPro][]                  | pinebookPro   | [Does not work yet](https://github.com/Mic92/nixos-aarch64-images/issues/8) |

[Rock64]: https://nixos.wiki/wiki/NixOS_on_ARM/PINE64_ROCK64
[RockPro64]: https://nixos.wiki/wiki/NixOS_on_ARM/PINE64_ROCKPro64
[roc-pc-rk3399]: https://nixos.wiki/wiki/NixOS_on_ARM/Libre_Computer_ROC-RK3399-PC
[PinebookPro]: https://nixos.wiki/wiki/NixOS_on_ARM/PINE64_Pinebook_Pro

## Add a new board

See `images/rockchip.nix` for an example.
All options are defined in [here](pkgs/build-image/options.nix);

## Board wishlist

Allwinner boards have their bootloader in a free space after mbr:

https://nixos.wiki/wiki/Template:ARM/installation_allwinner
