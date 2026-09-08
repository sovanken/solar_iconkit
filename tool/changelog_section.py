"""Extract one version's section from CHANGELOG.md.

    python tool/changelog_section.py 1.2.0            # print to stdout
    python tool/changelog_section.py 1.2.0 -o body.md

Used by the release workflow so GitHub Release notes are the changelog
rather than a second, drifting copy of it. Exits non-zero when the version
has no section, which makes a forgotten changelog entry fail the release
instead of publishing silently.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

CHANGELOG = Path(__file__).resolve().parent.parent / "CHANGELOG.md"


def section_for(version: str, text: str) -> str | None:
    """The body under `## [version]`, up to the next `## [` heading."""
    heading = re.compile(
        r"^##\s*\[%s\].*$" % re.escape(version), re.M)
    match = heading.search(text)
    if not match:
        return None
    start = match.end()
    nxt = re.search(r"^##\s*\[", text[start:], re.M)
    body = text[start:start + nxt.start()] if nxt else text[start:]
    return body.strip()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("version", help="e.g. 1.2.0")
    parser.add_argument("-o", "--output", type=Path)
    args = parser.parse_args()

    text = CHANGELOG.read_text(encoding="utf-8")
    body = section_for(args.version, text)
    if not body:
        print(f"CHANGELOG.md has no '## [{args.version}]' section.",
              file=sys.stderr)
        return 1

    if args.output:
        args.output.write_text(body + "\n", encoding="utf-8")
    else:
        # The changelog contains arrows and typographic quotes; Windows
        # consoles default to cp1252 and would raise on them.
        try:
            sys.stdout.reconfigure(encoding="utf-8")
        except (AttributeError, OSError):
            pass
        print(body)
    return 0


if __name__ == "__main__":
    sys.exit(main())
