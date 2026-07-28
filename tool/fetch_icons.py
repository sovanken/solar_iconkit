"""Fetch all Solar SVGs from Iconify and generate the Dart constants file.

Run once from the package root:
    python tools/fetch_icons.py

Requires: Python 3.10+, `requests` (pip install requests).
Writes:
    assets/icons/{style}/{name}.svg      (7,401 files)
    lib/src/solar_iconkit_data.g.dart    (~1,231 constants)
"""

from __future__ import annotations

import json
import re
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path

# ---- config ----
API = "https://api.iconify.design"
PREFIX = "solar"
STYLES = [
    ("linear", "linear"),
    ("outline", "outline"),
    ("broken", "broken"),
    ("bold", "bold"),
    ("line-duotone", "line_duotone"),
    ("bold-duotone", "bold_duotone"),
]
BATCH_SIZE = 60  # icons per fetch — under URL length limit
BASE_STYLE_SUFFIX = "-linear"

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets" / "icons"
DART_OUT = ROOT / "lib" / "src" / "solar_iconkit_data.g.dart"


_USER_AGENT = (
    "solar_iconkit-fetcher/0.1 "
    "(+https://github.com/example/solar_iconkit; internal Flutter package build)"
)


def _http_json(url: str) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": _USER_AGENT})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode("utf-8"))


def fetch_base_names() -> list[str]:
    print("Fetching collection metadata...")
    data = _http_json(f"{API}/collection?prefix={PREFIX}")
    bases: set[str] = set()
    for names in data.get("categories", {}).values():
        for n in names:
            if n.endswith(BASE_STYLE_SUFFIX):
                bases.add(n[: -len(BASE_STYLE_SUFFIX)])
    for n in data.get("uncategorized", []):
        if n.endswith(BASE_STYLE_SUFFIX):
            bases.add(n[: -len(BASE_STYLE_SUFFIX)])
    result = sorted(bases)
    print(f"  found {len(result):,} base icons")
    return result


def fetch_style(base_names: list[str], api_suffix: str, folder: str) -> int:
    style_dir = ASSETS / folder
    style_dir.mkdir(parents=True, exist_ok=True)
    written = 0
    total = len(base_names)
    print(f"\nFetching style '{folder}' ({total:,} icons)...")
    for i in range(0, total, BATCH_SIZE):
        chunk = base_names[i : i + BATCH_SIZE]
        names_param = ",".join(f"{n}-{api_suffix}" for n in chunk)
        url = f"{API}/{PREFIX}.json?icons={names_param}"
        try:
            data = _http_json(url)
        except (urllib.error.URLError, TimeoutError) as e:
            print(f"  batch {i // BATCH_SIZE + 1} failed: {e}", file=sys.stderr)
            continue
        icons = data.get("icons", {})
        suffix_len = len(f"-{api_suffix}")
        for full_name, meta in icons.items():
            base = full_name[:-suffix_len]
            width = meta.get("width", 24)
            height = meta.get("height", 24)
            body = meta["body"]
            svg = (
                f'<svg xmlns="http://www.w3.org/2000/svg" '
                f'viewBox="0 0 {width} {height}">{body}</svg>'
            )
            (style_dir / f"{base}.svg").write_text(svg, encoding="utf-8")
            written += 1
        done = min(i + BATCH_SIZE, total)
        print(f"  {done:>5,} / {total:,}", end="\r", flush=True)
        time.sleep(0.05)  # gentle on the API
    print(f"  wrote {written:,} SVGs to {style_dir}")
    return written


# Dart reserved words + built-in identifiers + contextual keywords.
# Kept as a single set so `to_camel_case` can rename any collision.
# Sources: Dart language spec + dart.dev/guides/language/language-tour.
DART_RESERVED = {
    # Dart reserved words (never allowed as identifiers)
    "assert", "break", "case", "catch", "class", "const", "continue",
    "default", "do", "else", "enum", "extends", "false", "final", "finally",
    "for", "if", "in", "is", "new", "null", "rethrow", "return", "super",
    "switch", "this", "throw", "true", "try", "var", "void", "while", "with",
    # Built-in identifiers (context-sensitive but risky as class members)
    "abstract", "as", "covariant", "deferred", "dynamic", "export",
    "extension", "external", "factory", "function", "get", "implements",
    "import", "interface", "late", "library", "mixin", "operator", "part",
    "required", "set", "sealed", "static", "typedef",
    # Contextual keywords
    "async", "await", "hide", "of", "on", "show", "sync", "when", "yield",
    "base",
}


def to_camel_case(name: str) -> str:
    parts = re.split(r"[-_]+", name)
    parts = [p for p in parts if p]
    if not parts:
        return "unnamed"
    head = parts[0].lower()
    tail = "".join(p[:1].upper() + p[1:].lower() for p in parts[1:])
    ident = head + tail
    if ident[0].isdigit():
        ident = "i" + ident
    if ident in DART_RESERVED:
        ident = f"{ident}Icon"
    return ident


def generate_dart(base_names: list[str]) -> None:
    print(f"\nGenerating {DART_OUT.relative_to(ROOT)}...")
    lines: list[str] = []
    lines.append("// GENERATED FILE. Do not edit by hand.")
    lines.append("// Run `python tools/fetch_icons.py` to regenerate.")
    lines.append("")
    lines.append("// ignore_for_file: constant_identifier_names")
    lines.append("")
    lines.append("/// All Solar icon base names, exposed as string constants.")
    lines.append("///")
    lines.append("/// Use with [SolarIcon]:")
    lines.append("/// ```dart")
    lines.append("/// SolarIcon(SolarIcons.home2, style: SolarIconStyle.linear)")
    lines.append("/// ```")
    lines.append("class SolarIcons {")
    lines.append("  const SolarIcons._();")
    lines.append("")

    seen: dict[str, str] = {}
    for name in base_names:
        ident = to_camel_case(name)
        # Handle collisions by appending an index
        original = ident
        n = 2
        while ident in seen:
            ident = f"{original}{n}"
            n += 1
        seen[ident] = name
        lines.append(f"  static const String {ident} = '{name}';")

    lines.append("")
    lines.append(f"  /// Every icon in the set, sorted alphabetically ({len(base_names):,} entries).")
    lines.append("  static const List<String> all = <String>[")
    for name in base_names:
        lines.append(f"    '{name}',")
    lines.append("  ];")
    lines.append("}")
    lines.append("")

    DART_OUT.parent.mkdir(parents=True, exist_ok=True)
    DART_OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"  wrote {len(base_names):,} constants + all[] list")


def main() -> int:
    bases = fetch_base_names()
    if not bases:
        print("No icons found — aborting.", file=sys.stderr)
        return 1
    total = 0
    for api_suffix, folder in STYLES:
        total += fetch_style(bases, api_suffix, folder)
    generate_dart(bases)
    print(f"\nDone. {total:,} SVGs, {len(bases):,} Dart constants.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
