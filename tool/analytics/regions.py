"""Slovenian NUTS-3 regions: load, assign a point, project to the map viewBox.

Boundaries: Eurostat GISCO NUTS-3 2021 (`assets/si_nuts3.geojson`).
"""
import json
import math
from pathlib import Path

HERE = Path(__file__).resolve().parent
W, H, MARGIN = 960, 480, 16


def load():
    raw = json.loads((HERE / "assets" / "si_nuts3.geojson").read_text(encoding="utf-8"))
    regions = []
    for f in raw["features"]:
        geom = f["geometry"]
        polys = geom["coordinates"] if geom["type"] == "MultiPolygon" else [geom["coordinates"]]
        regions.append({
            "id": f["properties"]["NUTS_ID"],
            "name": f["properties"]["NUTS_NAME"],
            # outer ring only — Slovenia's NUTS-3 areas have no holes
            "rings": [poly[0] for poly in polys],
        })
    return regions


def projector(regions):
    """Equirectangular fit of all rings into the viewBox, latitude-corrected."""
    lngs = [p[0] for r in regions for ring in r["rings"] for p in ring]
    lats = [p[1] for r in regions for ring in r["rings"] for p in ring]
    kx = math.cos(math.radians((min(lats) + max(lats)) / 2))
    x0, x1 = min(lngs) * kx, max(lngs) * kx
    y0, y1 = min(lats), max(lats)
    scale = min((W - 2 * MARGIN) / (x1 - x0), (H - 2 * MARGIN) / (y1 - y0))
    dx = (W - (x1 - x0) * scale) / 2
    dy = (H - (y1 - y0) * scale) / 2

    def project(lng, lat):
        return (dx + (lng * kx - x0) * scale, H - dy - (lat - y0) * scale)

    return project


def _in_ring(x, y, ring):
    inside = False
    for (x1, y1), (x2, y2) in zip(ring, ring[1:] + ring[:1]):
        if (y1 > y) != (y2 > y) and x < x1 + (y - y1) / (y2 - y1) * (x2 - x1):
            inside = not inside
    return inside


def assign(lng, lat, regions):
    """Region containing the point, else the nearest one with approx=True."""
    for r in regions:
        if any(_in_ring(lng, lat, ring) for ring in r["rings"]):
            return r, False
    nearest, best = None, None
    for r in regions:
        for ring in r["rings"]:
            for px, py in ring:
                d = math.hypot((px - lng) * math.cos(math.radians(lat)), py - lat)
                if best is None or d < best:
                    nearest, best = r, d
    return nearest, True


def centroid(ring):
    a = cx = cy = 0.0
    for (x1, y1), (x2, y2) in zip(ring, ring[1:] + ring[:1]):
        cross = x1 * y2 - x2 * y1
        a += cross
        cx += (x1 + x2) * cross
        cy += (y1 + y2) * cross
    return ring[0] if a == 0 else (cx / (3 * a), cy / (3 * a))


def svg_path(rings, project):
    out = []
    for ring in rings:
        pts = [project(lng, lat) for lng, lat in ring]
        out.append("M" + "L".join(f"{x:.1f},{y:.1f}" for x, y in pts) + "Z")
    return "".join(out)


def split(points, regions):
    """Aggregate snapshot points into per-region counts (users, not cells)."""
    counts = {r["id"]: 0 for r in regions}
    approx = 0
    for p in points:
        region, is_approx = assign(p["lng"], p["lat"], regions)
        counts[region["id"]] += p["n"]
        approx += is_approx
    placed = sum(counts.values())
    rows = [{
        "id": r["id"], "name": r["name"], "n": counts[r["id"]],
        "pct": round(100 * counts[r["id"]] / placed, 1) if placed else 0.0,
    } for r in regions]
    rows.sort(key=lambda r: (-r["n"], r["name"]))
    return rows, approx
