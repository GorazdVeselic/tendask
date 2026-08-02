"""Report one snapshot: how many users, how many by region, what moved since last time.

    python tool/analytics/report.py [--snapshot YYYY-MM-DD] [--vs YYYY-MM-DD] [--md]

A snapshot is a reading of "now" — the database keeps no history of when a cell
was set, so a past date can only be reported if a snapshot was taken that day.
The comparison splits growth into new signups vs existing users who added a
location later; the latter is what an in-app prompt (FR-22) moves.
"""
import argparse
import json
import sys

from db import REPO

sys.stdout.reconfigure(encoding="utf-8", errors="replace")  # Windows console is cp1250

SNAPSHOTS = REPO / "docs" / "analytics" / "snapshots"


def load(name):
    path = SNAPSHOTS / f"{name}.json"
    if not path.exists():
        have = ", ".join(p.stem for p in sorted(SNAPSHOTS.glob("*.json"))) or "none"
        raise SystemExit(f"no snapshot for {name}; have: {have}")
    return json.loads(path.read_text(encoding="utf-8"))


def newest_two():
    files = sorted(SNAPSHOTS.glob("*.json"))
    if not files:
        raise SystemExit(f"no snapshots in {SNAPSHOTS} — run snapshot.py first")
    return files[-1].stem, (files[-2].stem if len(files) > 1 else None)


def pct(part, whole):
    return f"{100 * part / whole:.1f} %" if whole else "—"


def print_text(snap, prev):
    label = f" — {snap['label']}" if snap.get("label") else ""
    print(f"Tendask, stanje {snap['date']}{label}")
    print(f"  uporabnikov skupaj:      {snap['total']}")
    print(f"  z nastavljeno lokacijo:  {snap['with_cell']}  ({pct(snap['with_cell'], snap['total'])} vseh)")
    print(f"  brez lokacije:           {snap['total'] - snap['with_cell']}")
    print(f"  ločenih celic (r5):      {len(snap['points'])}\n")

    before = {r["id"]: r["n"] for r in prev["regions"]} if prev else {}
    head = f"  {'regija':<24}{'upor.':>6}{'delež':>8}"
    print(head + (f"{'razlika':>10}" if prev else ""))
    for r in snap["regions"]:
        line = f"  {r['name']:<24}{r['n']:>6}{r['pct']:>7.1f} %"
        if prev:
            delta = r["n"] - before.get(r["id"], 0)
            line += f"{('+' + str(delta)) if delta > 0 else (str(delta) if delta else '·'):>10}"
        print(line)
    print(f"  {'skupaj razporejenih':<24}{sum(r['n'] for r in snap['regions']):>6}")
    if snap.get("approx_cells"):
        print(f"  ({snap['approx_cells']} celic ima središče v morju ali čez mejo — pripisane najbližji regiji)")

    if not prev:
        print("\nEn sam posnetek — za primerjavo posnemi še enega kasneje.")
        return

    new_signups = [d for d in snap["daily_new"] if d["d"] > prev["date"]]
    signups = sum(d["n"] for d in new_signups)
    signups_with = sum(d["with_cell"] for d in new_signups)
    gained = snap["with_cell"] - prev["with_cell"]
    retro = gained - signups_with
    print(f"\nOd {prev['date']} do {snap['date']}:")
    print(f"  novih uporabnikov:            {signups:+d}  (od teh {signups_with} z lokacijo, {pct(signups_with, signups)})")
    print(f"  skupaj z lokacijo:            {gained:+d}")
    print(f"  od tega obstoječi uporabniki: {retro:+d}  ← učinek povabila v aplikaciji")
    print(f"  delež z lokacijo: {pct(prev['with_cell'], prev['total'])} → {pct(snap['with_cell'], snap['total'])}")


def print_md(snap, prev):
    label = f" — {snap['label']}" if snap.get("label") else ""
    print(f"### {snap['date']}{label}\n")
    print(f"{snap['total']} uporabnikov, {snap['with_cell']} z lokacijo "
          f"({pct(snap['with_cell'], snap['total'])}), {len(snap['points'])} ločenih celic.\n")
    before = {r["id"]: r["n"] for r in prev["regions"]} if prev else {}
    print("| Regija | Uporabnikov | Delež |" + (" Razlika |" if prev else ""))
    print("|---|---|---|" + ("---|" if prev else ""))
    for r in snap["regions"]:
        row = f"| {r['name']} | {r['n']} | {r['pct']:.1f} % |"
        if prev:
            delta = r["n"] - before.get(r["id"], 0)
            row += f" {('+' + str(delta)) if delta > 0 else (str(delta) if delta else '—')} |"
        print(row)


def main():
    ap = argparse.ArgumentParser()
    newest, second = newest_two()
    ap.add_argument("--snapshot", default=newest, help="date to report; default = newest")
    ap.add_argument("--vs", default=None, help="compare against this snapshot; default = the one before")
    ap.add_argument("--md", action="store_true", help="markdown table, to paste into README")
    args = ap.parse_args()

    snap = load(args.snapshot)
    earlier = [p.stem for p in sorted(SNAPSHOTS.glob("*.json")) if p.stem < args.snapshot]
    prev_name = args.vs or (earlier[-1] if earlier else None)
    prev = load(prev_name) if prev_name else None

    (print_md if args.md else print_text)(snap, prev)


if __name__ == "__main__":
    main()
