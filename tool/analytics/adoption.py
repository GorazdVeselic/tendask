"""Report on garden-location adoption: who sets a cell, and did that change?

    python tool/analytics/adoption.py [--release YYYY-MM-DD] [--weeks 8]

Reads the snapshots in docs/analytics/snapshots. Two independent readings:

  * signup cohorts — of the profiles first seen in a period, how many carry a
    cell today. Clean for onboarding changes: a cohort only ever saw one build.
  * snapshot delta — how the overall count moved between two snapshots. The
    only way to see EXISTING users adding a location later, since the database
    stores no timestamp for when the cell itself was set.
"""
import argparse
import json
import sys
from datetime import date, timedelta

from db import REPO

sys.stdout.reconfigure(encoding="utf-8", errors="replace")  # Windows console is cp1250

SNAPSHOTS = REPO / "docs" / "analytics" / "snapshots"


def load_all():
    return [json.loads(p.read_text(encoding="utf-8")) for p in sorted(SNAPSHOTS.glob("*.json"))]


def pct(part, whole):
    return f"{100 * part / whole:5.1f} %" if whole else "    — "


def weekly(daily, weeks):
    if not daily:
        return []
    last = date.fromisoformat(daily[-1]["d"])
    start = last - timedelta(days=7 * weeks - 1)
    buckets = {}
    for row in daily:
        day = date.fromisoformat(row["d"])
        if day < start:
            continue
        # windows of 7 days counted back from the newest day, keyed by their first day
        key = last - timedelta(days=7 * ((last - day).days // 7) + 6)
        b = buckets.setdefault(key, {"n": 0, "with_cell": 0})
        b["n"] += row["n"]
        b["with_cell"] += row["with_cell"]
    return sorted(buckets.items())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--release", default=None, help="date the changed build went out")
    ap.add_argument("--weeks", type=int, default=8)
    args = ap.parse_args()

    snaps = load_all()
    if not snaps:
        raise SystemExit(f"no snapshots in {SNAPSHOTS} — run snapshot.py first")
    snap = snaps[-1]

    print(f"snapshot {snap['date']}"
          f"{' — ' + snap['label'] if snap.get('label') else ''}")
    print(f"  {snap['with_cell']} of {snap['total']} profiles have a location "
          f"({pct(snap['with_cell'], snap['total']).strip()})\n")

    print(f"signup cohorts, last {args.weeks} weeks (week starting → new profiles → with location)")
    for week, b in weekly(snap["daily_new"], args.weeks):
        bar = "#" * round(20 * b["with_cell"] / b["n"]) if b["n"] else ""
        print(f"  {week}  {b['n']:>3} new  {b['with_cell']:>3} with cell  {pct(b['with_cell'], b['n'])}  {bar}")

    if args.release:
        before = [d for d in snap["daily_new"] if d["d"] < args.release]
        after = [d for d in snap["daily_new"] if d["d"] >= args.release]
        print(f"\ncohorts split at {args.release}")
        for name, rows in (("before", before), ("on/after", after)):
            n = sum(d["n"] for d in rows)
            c = sum(d["with_cell"] for d in rows)
            print(f"  {name:<9} {n:>4} profiles  {c:>4} with cell  {pct(c, n)}")
        if sum(d["n"] for d in after) < 30:
            print("  (n is small — read as an indication, not a result)")

    if len(snaps) > 1:
        print("\nsnapshot deltas (includes existing users adding a location later)")
        prev = snaps[0]
        for cur in snaps[1:]:
            dn = cur["total"] - prev["total"]
            dc = cur["with_cell"] - prev["with_cell"]
            new_ones = sum(d["n"] for d in cur["daily_new"] if d["d"] > prev["date"])
            retro = dc - sum(d["with_cell"] for d in cur["daily_new"] if d["d"] > prev["date"])
            print(f"  {prev['date']} → {cur['date']}:  profiles {dn:+d}, with cell {dc:+d} "
                  f"({new_ones} new signups, {retro:+d} from profiles that already existed)")
            prev = cur
    else:
        print("\nonly one snapshot — take another later to see existing users adding a location")


if __name__ == "__main__":
    main()
