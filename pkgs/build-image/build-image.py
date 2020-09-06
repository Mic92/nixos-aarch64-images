#!/usr/bin/env python3

import subprocess
import sys
import json
from dataclasses import dataclass
from typing import Optional, Dict, Union, List, Tuple, Any
from curses.ascii import isprint, iscntrl


# see https://github.com/karelzak/util-linux/blob/050def0f3511f743d948458ecd3fda637168a7c7/include/carefulputc.h#L107
def sfdisk_escape_string(value: str):
    chars = []
    for char in map(chr, value.encode("utf-8")):
        if not isprint(char) or iscntrl(char) or char in ['"', "\\", "`", "$"]:
            hex_val = hex(int(char))
            chars.append(f"\\x{hex_val}")
        else:
            chars.append(char)
    return '"' + "".join(chars) + '"'


@dataclass
class Partition:
    name: str
    start: int
    file: str
    source: str
    type: str
    size: Optional[int] = None
    source_size: Optional[int] = None
    source_offset: int = 0
    # ignored if mbr is used
    attrs: Optional[str] = None

    def to_sfdisk(self) -> str:
        line = f"{self.file}: "
        attributes: Dict[str, Union[int, str, None]]
        attributes = dict(
            name=self.name,
            start=self.start,
            size=self.size,
            type=self.type,
            attrs=self.attrs,
        )
        raw_attrs = []
        for name, value in attributes.items():
            serialized = None
            if value is None:
                continue
            elif isinstance(value, int):
                serialized = hex(value)
            elif isinstance(value, str):
                serialized = sfdisk_escape_string(value)
            raw_attrs.append(f"{name}={serialized}")
        line += ", ".join(raw_attrs)
        return line

    def to_dd_args(self) -> List[str]:
        args = {
            "if": self.source,
            "of": self.file,
            "skip": self.source_offset * 512,
            "seek": self.start * 512,
            "status": "progress",
            "iflag": "direct,count_bytes,skip_bytes",
            "oflag": "direct,seek_bytes",
            "bs": "16M",
            "conv": "fsync,notrunc",
        }
        if self.size:
            args["count"] = self.size * 512
        elif self.source_size:
            args["count"] = self.source_size * 512

        final = []
        for key, value in args.items():
            final.append(f"{key}={value}")
        return final


def get_disk_layout(format: str, partitions: List[Partition], first_lba: int) -> str:
    layout = f"""
label: {format}
unit: sectors
first-lba: {first_lba}
    """
    lines = [layout]
    lines.extend(p.to_sfdisk() for p in partitions)
    return "\n".join(lines) + "\n"


def find_bootable_partition(image: str, out_file: str) -> Tuple[int, int]:
    proc = subprocess.run(
        ["sfdisk", "--json", image], text=True, check=True, stdout=subprocess.PIPE
    )
    data = json.loads(proc.stdout)
    table = data["partitiontable"]
    for partition in table["partitions"]:
        if partition.get("bootable"):
            return partition["start"], partition["size"]
    raise RuntimeError(f"no bootable image found in {image}")


def get_partition(p: Dict[str, Any], out_file: str) -> Partition:
    if p["useBootPartition"]:
        start, size = find_bootable_partition(p["source"], out_file)
        p["sourceOffset"] = start
        p["sourceSize"] = size
    partition = Partition(
        name=p["name"],
        start=p["start"],
        size=p["size"],
        source_size=p.get("sourceSize"),
        source_offset=p.get("sourceOffset", 0),
        file=out_file,
        source=p["source"],
        attrs=p["attrs"],
        type=p["type"],
    )
    return partition


def compute_image_size(partitions: List[Partition]) -> int:
    # leave some space for backup gpt
    size = 97
    for p in partitions:
        if p.size is None:
            if p.source_size is None:
                cmd = ["du", "-B", "512", "--apparent-size", p.source]
                proc = subprocess.run(cmd, check=True, stdout=subprocess.PIPE)
                size += int(proc.stdout)
            else:
                size += p.source_size
        else:
            size += p.size
    return size


def get_partitions(
    raw_partitions: Dict[str, Dict[str, Any]], out_file: str
) -> List[Partition]:
    partitions = []
    for _, p in raw_partitions.items():
        partitions.append(get_partition(p, out_file))
    partitions.sort(key=lambda p: p.start)
    return partitions


def main() -> None:
    if len(sys.argv) < 3:
        print(f"USAGE: {sys.argv[0]} manifest.nix out_file")
        sys.exit(1)
    with open(sys.argv[1]) as f:
        manifest = json.load(f)
    out_file = sys.argv[2]
    partitions = get_partitions(manifest["partitions"], out_file)

    layout = get_disk_layout(
        first_lba=manifest["firstLba"],
        format=manifest["format"],
        partitions=partitions
    )
    size = compute_image_size(partitions)
    with open(out_file, "w") as f:
        f.truncate(size * 512)

    print(f"sfdisk {out_file} <<'EOF'{layout}EOF")
    subprocess.run(["sfdisk", out_file], input=layout, text=True, check=True)
    for partition in partitions:
        dd_cmd = ["dd"] + partition.to_dd_args()
        print(f"$ {' '.join(dd_cmd)}")
        subprocess.run(dd_cmd, check=True)

    # check that we did not break anything
    verify_cmd = ["sfdisk", "--verify", out_file]
    print(f"$ {' '.join(verify_cmd)}")
    subprocess.run(verify_cmd)


if __name__ == "__main__":
    main()
