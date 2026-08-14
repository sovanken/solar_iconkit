"""Fetch all Solar SVGs from Iconify and generate the Dart constants file.

Run once from the package root:
    python tool/fetch_icons.py

Requires: Python 3.10+ (standard library only).
Writes:
    assets/icons/{style}/{name}.svg      (one file per canonical name, per style)
    lib/src/solar_iconkit_data.g.dart    (canonical + deprecated legacy constants)

## Why this script is not a plain "download everything" loop

Upstream Solar renames icons. Iconify keeps the old names reachable — some as
`aliases`, some merely as `hidden` entries — but drops them from the browsable
collection listing. A naive regeneration that reads only the visible listing
would silently delete every renamed constant, breaking consumers who upgrade.

So the script computes two sets:

* **canonical** — the names Solar currently advertises. These get SVG assets
  and normal constants.
* **legacy** — names a previous release shipped that are no longer canonical.
  These get `@Deprecated` constants whose *value* is the canonical name, plus
  an entry in [SolarIcons.legacyAliases] so raw-string callers still resolve.
  They cost no extra SVG files.

A legacy name that cannot be mapped to any canonical name keeps its own assets
rather than disappearing.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
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
# Longest-first so `-line-duotone` is stripped before `-linear` never matches it.
API_SUFFIXES = sorted((s for s, _ in STYLES), key=len, reverse=True)

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets" / "icons"
DART_OUT = ROOT / "lib" / "src" / "solar_iconkit_data.g.dart"

# Renames Iconify records only as `hidden` entries, with no alias target to
# follow. Each pair below was confirmed by rasterising both glyphs and diffing
# the pixels — they are the same drawing under a corrected name.
HIDDEN_RENAMES = {
    "4k": "four-k",
    "archive-down-minimlistic": "archive-down-minimalistic",
    "archive-up-minimlistic": "archive-up-minimalistic",
    "card-recive": "card-receive",
    "file-favourite": "file-favorite",
    "gallery-favourite": "gallery-favorite",
    "magic-stick": "magic-wand",
    "magic-stick-2": "magic-wand-2",
    "map-point-favourite": "map-point-favorite",
    "pallete-2": "palette-2",
    "plain": "plane",
    "recive-square": "receive-square",
    "recive-twice-square": "receive-twice-square",
    "winrar": "win-rar",
}

# Aliases whose recorded parent is circular or points at a style-specific
# entry, so the generic resolver cannot use it.
ALIAS_OVERRIDES = {
    "sort-by-alphabet": "sort-alphabetically",
}


_USER_AGENT = (
    "solar_iconkit-fetcher/0.2 "
    "(+https://github.com/sovanken/solar_iconkit; regeneration script)"
)


def _http_json(url: str) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": _USER_AGENT})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode("utf-8"))


def strip_style(full_name: str) -> str:
    """Strip whichever style suffix `full_name` carries."""
    for suffix in API_SUFFIXES:
        if full_name.endswith("-" + suffix):
            return full_name[: -len(suffix) - 1]
    return full_name


def fetch_collection() -> dict:
    print("Fetching collection metadata...")
    return _http_json(f"{API}/collection?prefix={PREFIX}")


def canonical_names(data: dict) -> list[str]:
    """The base names Solar currently advertises in its browsable listing."""
    bases: set[str] = set()
    for names in data.get("categories", {}).values():
        for n in names:
            if n.endswith(BASE_STYLE_SUFFIX):
                bases.add(n[: -len(BASE_STYLE_SUFFIX)])
    for n in data.get("uncategorized", []):
        if n.endswith(BASE_STYLE_SUFFIX):
            bases.add(n[: -len(BASE_STYLE_SUFFIX)])
    result = sorted(bases)
    print(f"  found {len(result):,} canonical icons")
    return result


def previously_shipped() -> list[str]:
    """Names in the committed catalog, i.e. what the last release exposed."""
    if not DART_OUT.exists():
        return []
    text = DART_OUT.read_text(encoding="utf-8")
    match = re.search(
        r"static const List<String> all = <String>\[(.*?)\];", text, re.S)
    if not match:
        return []
    return re.findall(r"'([^']+)'", match.group(1))


def resolve_legacy(
    data: dict, canonical: set[str], previous: list[str]
) -> tuple[dict[str, str], list[str]]:
    """Map each retired name to its canonical replacement.

    Returns (mapping, unresolved) where `unresolved` names must keep shipping
    their own SVG assets because no replacement could be determined.
    """
    aliases = data.get("aliases", {})
    mapping: dict[str, str] = {}
    unresolved: list[str] = []
    for name in previous:
        if name in canonical:
            continue
        target = ALIAS_OVERRIDES.get(name) or HIDDEN_RENAMES.get(name)
        if target is None:
            # `/collection` records an alias as a bare parent name; the icon
            # data endpoint uses {"parent": ...}. Accept either shape.
            entry = aliases.get(name + BASE_STYLE_SUFFIX)
            if isinstance(entry, dict):
                entry = entry.get("parent")
            if isinstance(entry, str) and entry:
                candidate = strip_style(entry)
                if candidate != name and candidate in canonical:
                    target = candidate
        if target in canonical:
            mapping[name] = target
        else:
            unresolved.append(name)
    print(f"  {len(mapping):,} retired names mapped to replacements")
    if unresolved:
        print(f"  {len(unresolved)} kept as standalone assets: "
              f"{', '.join(unresolved)}")
    return mapping, unresolved


def fetch_style(names: list[str], api_suffix: str, folder: str) -> int:
    style_dir = ASSETS / folder
    style_dir.mkdir(parents=True, exist_ok=True)
    keep = {f"{n}.svg" for n in names}
    removed = 0
    for existing in style_dir.glob("*.svg"):
        if existing.name not in keep:
            existing.unlink()
            removed += 1
    written = 0
    total = len(names)
    print(f"\nFetching style '{folder}' ({total:,} icons)...")
    for i in range(0, total, BATCH_SIZE):
        chunk = names[i: i + BATCH_SIZE]
        names_param = ",".join(f"{n}-{api_suffix}" for n in chunk)
        url = f"{API}/{PREFIX}.json?icons={names_param}"
        try:
            data = _http_json(url)
        except (urllib.error.URLError, TimeoutError) as e:
            print(f"  batch {i // BATCH_SIZE + 1} failed: {e}", file=sys.stderr)
            continue
        icons = data.get("icons", {})
        default_w = data.get("width", 24)
        default_h = data.get("height", 24)
        suffix_len = len(f"-{api_suffix}")
        for full_name, meta in icons.items():
            base = full_name[:-suffix_len]
            width = meta.get("width", default_w)
            height = meta.get("height", default_h)
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
    note = f" ({removed} stale removed)" if removed else ""
    print(f"  wrote {written:,} SVGs to {style_dir}{note}")
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
    # Members declared on this class itself.
    "all", "legacyAliases",
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


def generate_dart(canonical: list[str], legacy: dict[str, str]) -> None:
    print(f"\nGenerating {DART_OUT.relative_to(ROOT)}...")
    lines: list[str] = []
    lines.append("// GENERATED FILE. Do not edit by hand.")
    lines.append("// Run `python tool/fetch_icons.py` to regenerate.")
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

    def unique(ident: str) -> str:
        original = ident
        n = 2
        while ident in seen:
            ident = f"{original}{n}"
            n += 1
        return ident

    for name in canonical:
        ident = unique(to_camel_case(name))
        seen[ident] = name
        lines.append(f"  /// Solar icon `{name}`.")
        lines.append(f"  static const String {ident} = '{name}';")

    if legacy:
        lines.append("")
        lines.append("  // ---- Retired names ----")
        lines.append("  //")
        lines.append("  // Solar renamed these icons upstream. Each constant now")
        lines.append("  // resolves to its replacement so existing code keeps")
        lines.append("  // compiling and rendering the same glyph.")
        lines.append("")
        for name in sorted(legacy):
            target = legacy[name]
            ident = unique(to_camel_case(name))
            seen[ident] = name
            lines.append(f"  /// Solar icon `{name}`, renamed to `{target}`.")
            lines.append(
                f"  @Deprecated(\"'{name}' was renamed to '{target}' upstream. \"")
            lines.append(
                f"      \"Use SolarIcons.{to_camel_case(target)} instead.\")")
            lines.append(f"  static const String {ident} = '{target}';")

    lines.append("")
    lines.append("  /// Every icon in the set, sorted alphabetically "
                 f"({len(canonical):,} entries).")
    lines.append("  ///")
    lines.append("  /// Retired names are excluded — see [legacyAliases].")
    lines.append("  static const List<String> all = <String>[")
    for name in canonical:
        lines.append(f"    '{name}',")
    lines.append("  ];")
    lines.append("")
    lines.append("  /// Maps each retired icon name to its current replacement.")
    lines.append("  ///")
    lines.append("  /// [SolarIcon] consults this map so raw strings such as")
    lines.append("  /// `SolarIcon('magnifer')` keep resolving after the rename.")
    lines.append(f"  /// ({len(legacy):,} entries.)")
    lines.append("  static const Map<String, String> legacyAliases = "
                 "<String, String>{")
    for name in sorted(legacy):
        lines.append(f"    '{name}': '{legacy[name]}',")
    lines.append("  };")
    lines.append("}")
    lines.append("")

    DART_OUT.parent.mkdir(parents=True, exist_ok=True)
    DART_OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"  wrote {len(canonical):,} constants, "
          f"{len(legacy):,} deprecated aliases, and all[]")

    # CI verifies `dart format`, so normalise the generated file here rather
    # than leaving a formatting failure for the next push to discover.
    try:
        subprocess.run(["dart", "format", str(DART_OUT)],
                       check=True, capture_output=True, shell=(sys.platform == "win32"))
        print("  formatted with `dart format`")
    except (OSError, subprocess.CalledProcessError) as e:
        print(f"  WARNING: could not run `dart format` ({e}). "
              f"Run it manually before committing.", file=sys.stderr)


def main() -> int:
    data = fetch_collection()
    canonical = canonical_names(data)
    if not canonical:
        print("No icons found — aborting.", file=sys.stderr)
        return 1

    previous = previously_shipped()
    legacy, unresolved = resolve_legacy(data, set(canonical), previous)

    # Names that lost their upstream listing but have no replacement still need
    # their own assets, otherwise upgrading would break existing callers.
    to_download = sorted(set(canonical) | set(unresolved))

    dropped = sorted(set(previous) - set(to_download) - set(legacy))
    if dropped:
        print(f"\nREFUSING TO DROP {len(dropped)} shipped names: "
              f"{', '.join(dropped)}", file=sys.stderr)
        return 1

    total = 0
    for api_suffix, folder in STYLES:
        total += fetch_style(to_download, api_suffix, folder)
    generate_dart(to_download, legacy)
    print(f"\nDone. {total:,} SVGs, {len(to_download):,} Dart constants, "
          f"{len(legacy):,} deprecated aliases.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
