#!/usr/bin/env bash

set -euo pipefail

python3 - "${1:-.}" <<'PY'
from pathlib import Path
import os
import sys

from fontTools.ttLib import TTFont

directory = Path(sys.argv[1])
targets = {
    "Roboto-Regular.ttf": ("Roboto", "Roboto", False),
    "Roboto-Italic.ttf": ("Roboto", "Roboto", True),
    "RobotoFlex-Regular.ttf": ("Roboto Flex", "RobotoFlex", False),
    "RobotoFlex-Italic.ttf": ("Roboto Flex", "RobotoFlex", True),
    "NotoSerif-Regular.ttf": ("Noto Serif", "NotoSerif", False),
    "NotoSerif-Italic.ttf": ("Noto Serif", "NotoSerif", True),
    "DroidSansMono.ttf": ("Droid Sans Mono", "DroidSansMono", False),
    "CutiveMono.ttf": ("Cutive Mono", "CutiveMono", False),
}
prefixes = (
    "Source Serif 4 Variable", "Source Serif Pro", "Source Serif 4",
    "SourceSerif4Variable", "SourceSerif4Roman", "SourceSerif4Italic",
    "SourceSerif4", "Inter Variable", "InterVariableItalic", "InterVariable",
    "Inter", "Fira Code", "FiraCodeRoman", "FiraCode",
)
identity_ids = {1, 2, 3, 4, 6, 16, 17, 18, 21, 22, 25}
timestamp = 3313612800  # 2009-01-01 UTC, in the OpenType epoch (1904).

for filename, (family, ps_family, italic) in targets.items():
    path = directory / filename
    if not path.is_file():
        raise SystemExit(f"Missing font: {path}")
    font = TTFont(path, recalcTimestamp=False)
    if "glyf" not in font:
        raise SystemExit(f"Expected an Android TrueType font: {path}")
    names = font["name"]
    instance_ids = {
        instance.postscriptNameID for instance in font["fvar"].instances
        if instance.postscriptNameID != 0xFFFF
    }
    for record in names.names:
        if record.nameID not in identity_ids | instance_ids:
            continue  # Preserve copyrights, licenses, authors, and style labels.
        value = record.toUnicode()
        for prefix in prefixes:
            if value.startswith(prefix):
                replacement = ps_family if " " not in prefix else family
                value = replacement + value[len(prefix):]
                break
        if record.nameID in {1, 16, 21}:
            value = family
        elif record.nameID in {2, 17, 22}:
            value = "Italic" if italic else "Regular"
        elif record.nameID == 3:
            value = f"ProtonAOSP:{ps_family}:{'Italic' if italic else 'Regular'}:{names.getDebugName(5)}"
        elif record.nameID in {4, 18}:
            value = family + (" Italic" if italic else " Regular")
        elif record.nameID == 6:
            value = ps_family + ("-Italic" if italic else "-Regular")
        elif record.nameID == 25:
            value = ps_family + ("Italic" if italic else "Roman")
        record.string = value.encode(record.getEncoding())
    # Set Windows font names
    for name_id, value in {
        1: family, 2: "Italic" if italic else "Regular",
        3: f"ProtonAOSP:{ps_family}:{'Italic' if italic else 'Regular'}:{names.getDebugName(5)}",
        4: family + (" Italic" if italic else " Regular"),
        6: ps_family + ("-Italic" if italic else "-Regular"),
        16: family, 17: "Italic" if italic else "Regular",
        25: ps_family + ("Italic" if italic else "Roman"),
    }.items():
        names.setName(value, name_id, 3, 1, 0x409)
    font["head"].created = font["head"].modified = timestamp
    if "DSIG" in font:
        del font["DSIG"]  # An original signature cannot describe modified data.
    temporary = path.with_suffix(".tmp")
    try:
        font.save(temporary)
        font.close()
        os.replace(temporary, path)
    finally:
        if temporary.exists():
            temporary.unlink()
    print(f"{filename}: {family}")
PY
