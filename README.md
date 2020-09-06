# NixOS aarch64 images

Build aarch64 images for ARM single board computer that require
custom uboot firmware.
It re-uses pre-build NixOS installation images,
so it can be also built on non aarch64 architectures.

```console
$ nix-build -A rock64
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
