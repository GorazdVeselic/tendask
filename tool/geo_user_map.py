"""Read-only probe + renderer: where users are, aggregated from profile H3 cells.

Reads PROD (counts per h3_r5 only, never per-user rows), decodes each cell to its
centre, places it in an official statistical region, and renders a self-contained
HTML map. See docs/analitika-geo.md — especially the k-anonymity rules before any
of this output is published anywhere public.

    pip install h3 psycopg          # dev-only tools, not app dependencies
    python tool/geo_user_map.py     # -> tmp/geo/map_data.json + tmp/geo/map.html
"""
import base64
import json
import math
import pathlib
import re
import urllib.request

import h3
import psycopg

ROOT = pathlib.Path(__file__).resolve().parent.parent
OUT = ROOT / "tmp" / "geo"
FONT = ROOT / "assets" / "fonts" / "PlusJakartaSans-VariableFont_wght.ttf"
TEMPLATE = ROOT / "tool" / "geo_user_map.tpl.html"

# NUTS-3 for Slovenia == the 12 statistical regions. 2021 edition, 1:1M generalisation.
NUTS_URL = ("https://gisco-services.ec.europa.eu/distribution/v2/nuts/geojson/"
            "NUTS_RG_01M_2021_4326_LEVL_3.geojson")
REGION_NAMES = {
    "SI031": "Pomurska", "SI032": "Podravska", "SI033": "Koroška", "SI034": "Savinjska",
    "SI035": "Zasavska", "SI036": "Posavska", "SI037": "Jugovzhodna Slovenija",
    "SI038": "Primorsko-notranjska", "SI041": "Osrednjeslovenska", "SI042": "Gorenjska",
    "SI043": "Goriška", "SI044": "Obalno-kraška",
}
W, H, PAD = 960, 480, 14
SIMPLIFY_PX = 0.45          # Douglas-Peucker tolerance, in output pixels
MIN_PART_AREA_PX = 3.0      # drop coastline slivers that render as dust


# --- inputs ------------------------------------------------------------------

def load_regions():
    """Country subset of the NUTS-3 collection, cached — the full file is ~28 MB."""
    cache = OUT / "si_nuts3.geojson"
    if not cache.exists():
        OUT.mkdir(parents=True, exist_ok=True)
        raw = json.loads(urllib.request.urlopen(NUTS_URL, timeout=300).read())
        si = [f for f in raw["features"] if f["properties"]["CNTR_CODE"] == "SI"]
        cache.write_text(json.dumps({"type": "FeatureCollection", "features": si}), encoding="utf-8")
    feats = json.loads(cache.read_text(encoding="utf-8"))["features"]
    return {f["properties"]["NUTS_ID"]: f for f in feats}


def load_counts():
    """(total profiles, profiles with a cell, [(cell, n), ...]) from PROD. Read-only."""
    pwd = re.search(r":\s*(\S+)", (ROOT / ".env").read_text(encoding="utf-8-sig")).group(1)
    conn = psycopg.connect(host="aws-1-eu-central-1.pooler.supabase.com", port=5432,
                           user="postgres.jlmkkeijmmnwkizutvkg", password=pwd,
                           dbname="postgres", sslmode="require")
    try:
        with conn.cursor() as cur:
            cur.execute("select count(*), count(h3_r5) from public.profile")
            total, with_cell = cur.fetchone()
            cur.execute("select h3_r5, count(*) from public.profile "
                        "where h3_r5 is not null group by 1")
            return total, with_cell, cur.fetchall()
    finally:
        conn.close()


# --- geometry ----------------------------------------------------------------

def polygons(geom):
    return [geom["coordinates"]] if geom["type"] == "Polygon" else geom["coordinates"]


def in_polygon(lng, lat, poly):
    """Ray casting over an outer ring plus holes."""
    inside = False
    for idx, ring in enumerate(poly):
        crossings = False
        for i in range(len(ring)):
            x1, y1 = ring[i][0], ring[i][1]
            x2, y2 = ring[(i + 1) % len(ring)][0], ring[(i + 1) % len(ring)][1]
            if (y1 > lat) != (y2 > lat) and lng < (x2 - x1) * (lat - y1) / (y2 - y1) + x1:
                crossings = not crossings
        if idx == 0:
            inside = crossings
        elif crossings:
            return False
    return inside


def km_to_ring(lat, lng, ring):
    """Great-circle-ish distance from a point to a ring, good enough at country scale."""
    k = math.cos(math.radians(lat))
    best = float("inf")
    for i in range(len(ring) - 1):
        ax, ay, bx, by = ring[i][0] * k, ring[i][1], ring[i + 1][0] * k, ring[i + 1][1]
        dx, dy = bx - ax, by - ay
        t = 0.0 if dx == dy == 0 else max(0.0, min(1.0, ((lng * k - ax) * dx + (lat - ay) * dy) / (dx * dx + dy * dy)))
        best = min(best, 111.32 * math.hypot(lng * k - (ax + t * dx), lat - (ay + t * dy)))
    return best


def assign(cells, regions):
    """Cell -> region. An r5 centre can land in the sea or across a border, so a miss
    falls back to the nearest region rather than being dropped."""
    placed, counts = [], {}
    for cell, n in cells:
        lat, lng = h3.cell_to_latlng(cell)
        rid = next((k for k, f in regions.items()
                    for poly in polygons(f["geometry"]) if in_polygon(lng, lat, poly)), None)
        approx = None
        if rid is None:
            rid, approx = min(
                ((k, min(km_to_ring(lat, lng, p[0]) for p in polygons(f["geometry"])))
                 for k, f in regions.items()), key=lambda t: t[1])
        counts[rid] = counts.get(rid, 0) + n
        placed.append({"cell": cell, "n": n, "lat": lat, "lng": lng,
                       "region": rid, "approx_km": approx})
    return placed, counts


def make_projection(regions):
    """Equirectangular with a cos(lat) correction — honest at Slovenia's span.
    Anything wider than one country needs an equal-area projection instead."""
    pts = [p for f in regions.values() for poly in polygons(f["geometry"])
           for ring in poly for p in ring]
    lat0, lat1 = min(p[1] for p in pts), max(p[1] for p in pts)
    lng0, lng1 = min(p[0] for p in pts), max(p[0] for p in pts)
    k = math.cos(math.radians((lat0 + lat1) / 2))
    scale = min((W - 2 * PAD) / ((lng1 - lng0) * k), (H - 2 * PAD) / (lat1 - lat0))
    ox = PAD + ((W - 2 * PAD) - (lng1 - lng0) * k * scale) / 2
    oy = PAD + ((H - 2 * PAD) - (lat1 - lat0) * scale) / 2
    return lambda lng, lat: (ox + (lng - lng0) * k * scale, oy + (lat1 - lat) * scale)


def simplify(points, tol):
    """Douglas-Peucker."""
    if len(points) < 3:
        return points
    (ax, ay), (bx, by) = points[0], points[-1]
    dx, dy = bx - ax, by - ay
    worst, at = 0.0, 0
    for i in range(1, len(points) - 1):
        px, py = points[i]
        d = (abs(dx * (ay - py) - (ax - px) * dy) / math.hypot(dx, dy)
             if (dx or dy) else math.hypot(px - ax, py - ay))
        if d > worst:
            worst, at = d, i
    if worst <= tol:
        return [points[0], points[-1]]
    return simplify(points[:at + 1], tol)[:-1] + simplify(points[at:], tol)


def area_px(points):
    return abs(sum(points[i][0] * points[i + 1][1] - points[i + 1][0] * points[i][1]
                   for i in range(len(points) - 1))) / 2


def build_paths(regions, counts, placed_total, project):
    out = []
    for rid, feature in regions.items():
        parts, outers = [], []
        for poly in polygons(feature["geometry"]):
            for idx, ring in enumerate(poly):
                pts = [project(p[0], p[1]) for p in ring]
                if area_px(pts) < MIN_PART_AREA_PX:
                    continue
                thin = simplify(pts, SIMPLIFY_PX)
                if len(thin) < 4:
                    continue
                parts.append("M" + "L".join(f"{x:.1f},{y:.1f}" for x, y in thin) + "Z")
                if idx == 0:
                    outers.append(pts)
        biggest = max(outers, key=area_px)
        n = counts.get(rid, 0)
        out.append({
            "id": rid, "name": REGION_NAMES[rid], "n": n,
            "pct": round(100 * n / placed_total, 1) if placed_total else 0.0,
            "d": "".join(parts),
            "cx": round(sum(p[0] for p in biggest) / len(biggest), 1),
            "cy": round(sum(p[1] for p in biggest) / len(biggest), 1),
        })
    return sorted(out, key=lambda r: -r["n"])


# --- output ------------------------------------------------------------------

def render(data):
    html = (TEMPLATE.read_text(encoding="utf-8")
            .replace("/*FONT*/", base64.b64encode(FONT.read_bytes()).decode())
            .replace("/*DATA*/", json.dumps(data, ensure_ascii=False, separators=(",", ":"))))
    (OUT / "map.html").write_text(html, encoding="utf-8")


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    regions = load_regions()
    total, with_cell, cells = load_counts()
    placed, counts = assign(cells, regions)
    project = make_projection(regions)

    data = {
        "w": W, "h": H, "total": total, "with_cell": with_cell,
        "placed": sum(counts.values()),
        "regions": build_paths(regions, counts, sum(counts.values()), project),
        "points": [{"x": round(project(c["lng"], c["lat"])[0], 1),
                    "y": round(project(c["lng"], c["lat"])[1], 1),
                    "n": c["n"], "approx": c["approx_km"] is not None} for c in placed],
    }
    (OUT / "map_data.json").write_text(
        json.dumps(data, ensure_ascii=False, indent=1), encoding="utf-8")
    render(data)

    print(f"profiles {total} | with cell {with_cell} | placed {data['placed']}")
    for c in placed:
        if c["approx_km"] is not None:
            print(f"  nearest-region fallback: {c['cell']} -> "
                  f"{REGION_NAMES[c['region']]} ({c['approx_km']:.1f} km)")
    for r in data["regions"]:
        print(f"  {r['name']:<24}{r['n']:>3}{r['pct']:>7.1f} %")
    print(f"-> {OUT / 'map.html'}")


if __name__ == "__main__":
    main()
