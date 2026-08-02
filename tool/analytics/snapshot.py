"""Take a dated snapshot of production geo + location-adoption aggregates.

    python tool/analytics/snapshot.py [--date YYYY-MM-DD] [--label "..."]

Writes docs/analytics/snapshots/<date>.json. Aggregates only: cell counts and
daily totals, never a per-user row. H3 r5 (~8.5 km edge) is the finest cell
stored — r7 would be street-level for a user base this small.
"""
import argparse
import json
from datetime import date

import h3

import regions as si
from db import REPO, connect

SNAPSHOTS = REPO / "docs" / "analytics" / "snapshots"


def cell_center(cell):
    try:
        return h3.cell_to_latlng(cell)
    except Exception:
        return h3.cell_to_latlng(h3.int_to_str(int(cell)))


def fetch(cur, sql):
    cur.execute(sql)
    cols = [d.name for d in cur.description]
    return [dict(zip(cols, row)) for row in cur.fetchall()]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--date", default=date.today().isoformat(), help="snapshot filename date")
    ap.add_argument("--label", default="", help="what changed around this snapshot")
    args = ap.parse_args()

    with connect() as conn, conn.cursor() as cur:
        overall = fetch(cur, """
            select count(*) total,
                   count(h3_r5) with_cell,
                   count(*) filter (where lang = 'sl') lang_sl,
                   min(server_inserted_at)::date first_seen,
                   max(server_inserted_at)::date last_seen
            from public.profile
        """)[0]

        cells = fetch(cur, """
            select h3_r5 cell, count(*) n
            from public.profile where h3_r5 is not null
            group by 1 order by n desc, 1
        """)

        daily_new = fetch(cur, """
            select server_inserted_at::date d, count(*) n, count(h3_r5) with_cell
            from public.profile group by 1 order by 1
        """)

        daily_touched = fetch(cur, """
            select updated_at::date d, count(*) n, count(h3_r5) with_cell
            from public.profile group by 1 order by 1
        """)

    points = []
    for row in cells:
        lat, lng = cell_center(row["cell"])
        points.append({"lat": round(lat, 4), "lng": round(lng, 4), "n": row["n"]})

    by_region, approx = si.split(points, si.load())

    snapshot = {
        "date": args.date,
        "label": args.label,
        "source": "prod public.profile (read-only aggregate)",
        "total": overall["total"],
        "with_cell": overall["with_cell"],
        "first_seen": str(overall["first_seen"]),
        "last_seen": str(overall["last_seen"]),
        "regions": by_region,
        "approx_cells": approx,
        "points": points,
        "daily_new": [{"d": str(r["d"]), "n": r["n"], "with_cell": r["with_cell"]} for r in daily_new],
        "daily_touched": [{"d": str(r["d"]), "n": r["n"], "with_cell": r["with_cell"]} for r in daily_touched],
    }

    SNAPSHOTS.mkdir(parents=True, exist_ok=True)
    out = SNAPSHOTS / f"{args.date}.json"
    out.write_text(json.dumps(snapshot, ensure_ascii=False, indent=1), encoding="utf-8")
    pct = 100 * snapshot["with_cell"] / snapshot["total"] if snapshot["total"] else 0
    print(f"{out}: {snapshot['total']} profiles, {snapshot['with_cell']} with cell ({pct:.1f} %), "
          f"{len(points)} distinct r5 cells, "
          f"{sum(1 for r in by_region if r['n'])} regions covered")


if __name__ == "__main__":
    main()
