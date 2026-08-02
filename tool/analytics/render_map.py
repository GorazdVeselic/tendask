"""Render a snapshot into a standalone map page.

    python tool/analytics/render_map.py [--snapshot YYYY-MM-DD] [--days 45]
                                        [--release YYYY-MM-DD] [--release-label "vc17"]

Writes docs/analytics/maps/<snapshot>.html — one self-contained file, no network.
Cells are assigned to the NUTS-3 region containing their centre; a centre that
falls in the sea or across the border goes to the nearest region and is flagged
`approx` so the page can say so.
"""
import argparse
import json
from pathlib import Path

import regions as si
from db import REPO

HERE = Path(__file__).resolve().parent
SNAPSHOTS = REPO / "docs" / "analytics" / "snapshots"
MAPS = REPO / "docs" / "analytics" / "maps"


def fill_days(daily, days):
    """Continuous day axis (gaps read as zero, not as compressed time)."""
    from datetime import date, timedelta
    if not daily:
        return []
    by_day = {d["d"]: d for d in daily}
    last = date.fromisoformat(daily[-1]["d"])
    first = max(date.fromisoformat(daily[0]["d"]), last - timedelta(days=days - 1))
    out, day = [], first
    while day <= last:
        iso = day.isoformat()
        row = by_day.get(iso, {"n": 0, "with_cell": 0})
        out.append({"d": iso, "n": row["n"], "with_cell": row["with_cell"]})
        day += timedelta(days=1)
    return out


def adoption_note(daily, release):
    if not release:
        return "Stolpec = novi profili tistega dne; obarvani del je tisti z nastavljeno lokacijo."
    before = [d for d in daily if d["d"] < release]
    after = [d for d in daily if d["d"] >= release]
    bn, bc = sum(d["n"] for d in before), sum(d["with_cell"] for d in before)
    an, ac = sum(d["n"] for d in after), sum(d["with_cell"] for d in after)
    pct = lambda c, n: f"{100 * c / n:.0f} %".replace(".", ",") if n else "—"
    return (f"Stolpec = novi profili tistega dne; obarvani del je tisti z nastavljeno lokacijo. "
            f"Pred izdajo: <b>{bc} od {bn}</b> ({pct(bc, bn)}). Po izdaji: <b>{ac} od {an}</b> ({pct(ac, an)}). "
            f"Pri tako majhnih številkah je to indic, ne dokaz.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--snapshot", default=None, help="snapshot date; default = newest")
    ap.add_argument("--days", type=int, default=45, help="days on the adoption chart")
    ap.add_argument("--release", default=None, help="mark this date on the chart")
    ap.add_argument("--release-label", default="izdaja")
    args = ap.parse_args()

    files = sorted(SNAPSHOTS.glob("*.json"))
    if not files:
        raise SystemExit(f"no snapshots in {SNAPSHOTS} — run snapshot.py first")
    path = SNAPSHOTS / f"{args.snapshot}.json" if args.snapshot else files[-1]
    snap = json.loads(path.read_text(encoding="utf-8"))

    shapes = si.load()
    project = si.projector(shapes)
    geometry = {r["id"]: r for r in shapes}

    points = []
    for p in snap["points"]:
        _, approx = si.assign(p["lng"], p["lat"], shapes)
        px, py = project(p["lng"], p["lat"])
        points.append({"x": round(px, 1), "y": round(py, 1), "n": p["n"], "approx": approx})

    # counts come from the snapshot — the map draws what was recorded that day
    out_regions = []
    for r in snap["regions"]:
        rings = geometry[r["id"]]["rings"]
        cx, cy = project(*si.centroid(max(rings, key=len)))
        out_regions.append({**r, "d": si.svg_path(rings, project), "cx": round(cx, 1), "cy": round(cy, 1)})
    placed = sum(r["n"] for r in out_regions)

    daily = fill_days(snap["daily_new"], args.days)
    data = {
        "date": snap["date"], "label": snap.get("label", ""),
        "total": snap["total"], "with_cell": snap["with_cell"], "placed": placed,
        "regions": out_regions, "points": points, "daily": daily,
        "release": args.release, "release_label": args.release_label,
        "adoption_note": adoption_note(daily, args.release),
    }

    template = (HERE / "map_template.html").read_text(encoding="utf-8")
    MAPS.mkdir(parents=True, exist_ok=True)
    out = MAPS / f"{snap['date']}.html"
    out.write_text(template.replace("__DATA__", json.dumps(data, ensure_ascii=False)), encoding="utf-8")
    print(f"{out}: {placed} users placed across {sum(1 for r in out_regions if r['n'])} regions, "
          f"{sum(1 for p in points if p['approx'])} cells snapped to nearest region")


if __name__ == "__main__":
    main()
