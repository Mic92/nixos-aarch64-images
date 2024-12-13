#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix gh
set -xeuo pipefail
if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <release> <path-to-image>"
  echo "Go to i.e. https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image_new_kernel_no_zfs.aarch64-linux"
  exit 1
fi
release=$1
store_path=$2

nix-store -r "$store_path"
image_name=$(echo "$store_path/sd-image/"*.zst)
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
ln -s "$image_name" "$tmpdir/nixos-sd-image-$release-aarch64-linux.img.zst"
# create release if it does not exist
if ! gh release view "$release" &>/dev/null; then
  gh release create "$release"
fi
gh release upload "$release" "$tmpdir/nixos-sd-image-$release-aarch64-linux.img.zst" --clobber
echo "Add this url to aarch64-image/default.nix and update the hash"
echo "https://github.com/Mic92/nixos-aarch64-images/releases/download/$release/nixos-sd-image-$release-aarch64-linux.img.zst"
