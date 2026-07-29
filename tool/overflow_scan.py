"""Flags Flutter's yellow/black overflow banner in screenshots.

The banner paints saturated yellow stripes over black; the stripes interrupt
each other, so the marker is the yellow *count* in a row, not a run.
"""
import sys
from PIL import Image


def scan(path):
    im = Image.open(path).convert('RGB')
    w, h = im.size
    px = im.load()
    hits = []
    for y in range(0, h, 2):
        n = 0
        for x in range(0, w, 2):
            r, g, b = px[x, y]
            if r > 150 and g > 150 and abs(r - g) < 30 and b < 110:
                n += 1
        if n > 60:
            hits.append(y)
    return hits


for p in sys.argv[1:]:
    hits = scan(p)
    print(
        f"{'OVERFLOW' if hits else 'ok      '} {p}"
        + (f"  rows {hits[0]}-{hits[-1]}" if hits else '')
    )
