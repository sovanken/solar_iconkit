"""Fail unless pana granted every available point.

    python3 tool/assert_pana_score.py pana.json

Written as a script rather than an inline `--exit-code-threshold` because a
crashed pana run can still exit 0 — on Windows it aborts with a sandbox
path error and returns success. Reading the JSON means "no score" is a
failure instead of a silent pass, and the offending section gets named.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: assert_pana_score.py <pana.json>", file=sys.stderr)
        return 2

    try:
        data = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as err:
        print(f"::error::could not read pana output: {err}")
        return 1

    scores = data.get("scores") or {}
    granted = scores.get("grantedPoints")
    maximum = scores.get("maxPoints")
    if granted is None or maximum is None:
        print("::error::pana produced no score — the analysis likely failed")
        return 1

    print(f"pana score: {granted}/{maximum}")
    if granted >= maximum:
        return 0

    for section in (data.get("report") or {}).get("sections") or []:
        got = section.get("grantedPoints", 0)
        cap = section.get("maxPoints", 0)
        if got < cap:
            print(f"::error::lost points in '{section.get('title')}': {got}/{cap}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
