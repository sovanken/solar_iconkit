"""Report whether upstream Solar has changed since the committed catalog.

Run manually or from CI:
    python tool/check_upstream.py            # human-readable report
    python tool/check_upstream.py --markdown report.md

Exits 0 whether or not there is drift — this is a report, not a test. CI
reads the `has_changes` line from the summary to decide whether to open an
issue, so a network failure fails loudly instead of silently reporting
"no new icons".

Deliberately reuses fetch_icons' own resolution so the report cannot drift
from what a regeneration would actually do.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import fetch_icons as gen  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--markdown", type=Path,
                        help="write a markdown report to this path")
    parser.add_argument("--github-output", type=Path,
                        help="append has_changes=<bool> for GitHub Actions")
    args = parser.parse_args()

    data = gen.fetch_collection()
    canonical = gen.canonical_names(data)
    if not canonical:
        print("Upstream returned no icons — treating as a failure rather "
              "than as 'nothing new'.", file=sys.stderr)
        return 1

    shipped, shipped_legacy = gen.previously_shipped()
    if not shipped:
        print("No committed catalog to compare against.", file=sys.stderr)
        return 1

    canonical_set = set(canonical)
    legacy, unresolved = gen.resolve_legacy(
        data, canonical_set, shipped, shipped_legacy)

    added = sorted(canonical_set - set(shipped))
    # Names we ship that upstream no longer lists. Those with a replacement
    # are renames worth acting on; the rest are retained on purpose.
    vanished = [n for n in shipped if n not in canonical_set]
    renamed = sorted((n, legacy[n]) for n in vanished if n in legacy)
    retained = sorted(n for n in vanished if n not in legacy)

    changed = bool(added or renamed)

    lines: list[str] = []
    lines.append(f"Upstream canonical icons: **{len(canonical):,}**")
    lines.append(f"Committed catalog: **{len(shipped):,}** "
                 f"(+{len(shipped_legacy):,} retired aliases)")
    lines.append("")

    if added:
        lines.append(f"### {len(added)} new icon(s) upstream")
        lines.append("")
        for name in added:
            lines.append(f"- `{name}`")
        lines.append("")
    if renamed:
        lines.append(f"### {len(renamed)} rename(s) since the last sync")
        lines.append("")
        for old, new in renamed:
            lines.append(f"- `{old}` → `{new}`")
        lines.append("")
    if retained:
        lines.append(f"Retained by design (hidden upstream, kept so existing "
                     f"code keeps working): {', '.join('`%s`' % n for n in retained)}")
        lines.append("")
    if not changed:
        lines.append("No new or renamed icons. Nothing to sync.")
        lines.append("")
    else:
        lines.append("To sync: `python tool/fetch_icons.py`, then run the "
                     "redraw check before releasing — upstream sometimes "
                     "redraws a glyph without renaming it, and only a pixel "
                     "diff catches that.")
        lines.append("")

    report = "\n".join(lines)
    print(report)
    print(f"has_changes={'true' if changed else 'false'}")

    if args.markdown:
        args.markdown.write_text(report, encoding="utf-8")
    if args.github_output:
        with args.github_output.open("a", encoding="utf-8") as fh:
            fh.write(f"has_changes={'true' if changed else 'false'}\n")
            fh.write(f"added_count={len(added)}\n")
            fh.write(f"renamed_count={len(renamed)}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
