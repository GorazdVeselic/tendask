// GOLDEN — the year of suggestions the engine produces for the simulated garden
// (season_fixture.ts) on weather seed 1. Regenerate by running
// season_sim_test.ts: on mismatch it prints the current calendar to stdout,
// ready to paste back here.
//
// Read the bottom block first. R5/R6/R2 sit at 1–4 cards a year each, which is
// what a once-a-season job should cost. R3 does not: 61× watering and 41×
// mowing for a user who never acts — 65 % of the year's cards and 74 % of its
// pushes, from two ignored cadence pairs. That is N25 in
// 19-najdbe-med-izvedbo.md, and it is why the R3 cap in the test is a
// high-water mark rather than a target.
export const kSeasonCalendar = `# Koledar predlogov 2026-01-01 → 2026-12-31
# Vrt: trata + jablana + paradižnik + malina + bazilika (rastlinjak).
# Uporabnik v tem teku ne izvede nobenega predloga — zgornja meja emisij.
# Skupaj: 156 predlogov · 129 pushov · največ na dan: 3
# Pushi po pravilu: R3 ×95 · R5 ×31 · R6 ×2 · R2 ×1

## Po mesecih
2026-01  R3 R3:water/up:p-basil ×6
2026-02  R3 R3:water/up:p-basil ×4 · R5 berries.treat.dormant/up:p-raspberry ×2
2026-03  R3 R3:water/up:p-basil ×5 · R3 R3:mow/ar:a-lawn ×3 · R5 berries.fertilize/up:p-raspberry ×3 · R5 fruit_tree.fertilize/up:p-apple ×3 · R5 lawn.lawn_weed_moss.moss/ar:a-lawn ×2 · R5 berries.treat.dormant/up:p-raspberry ×1 · R5 lawn.roll/ar:a-lawn ×1 · R5 lawn.scarify.spring/ar:a-lawn ×1 · R6 R6:sow/up:p-tomato ×1
2026-04  R3 R3:mow/ar:a-lawn ×5 · R3 R3:water/up:p-basil ×5 · R5 lawn.fertilize.spring/ar:a-lawn ×3 · R5 lawn.lawn_weed_moss.moss/ar:a-lawn ×2 · R5 lawn.overseed.spring/ar:a-lawn ×2 · R5 lawn.scarify.spring/ar:a-lawn ×2 · R5 vegetable.sow.direct/up:p-tomato ×2 · R2 R2:fertilize/up:p-apple ×1 · R5 berries.fertilize/up:p-raspberry ×1 · R5 fruit_tree.fertilize/up:p-apple ×1 · R5 lawn.lawn_weed_moss.weed/ar:a-lawn ×1 · R5 tomato.harden_off/up:p-tomato ×1 · R5 vegetable.plant/up:p-tomato ×1 · R6 R6:sow/up:p-tomato ×1
2026-05  R3 R3:water/up:p-basil ×6 · R3 R3:mow/ar:a-lawn ×5 · R5 lawn.lawn_weed_moss.weed/ar:a-lawn ×2 · R5 vegetable.plant/up:p-tomato ×2 · R5 vegetable.sow.direct/up:p-tomato ×2 · R5 lawn.overseed.spring/ar:a-lawn ×1
2026-06  R3 R3:mow/ar:a-lawn ×5 · R3 R3:water/up:p-basil ×5 · R5 lawn.lawn_weed_moss.weed/ar:a-lawn ×1
2026-07  R3 R3:mow/ar:a-lawn ×5 · R3 R3:water/up:p-basil ×5
2026-08  R3 R3:mow/ar:a-lawn ×6 · R3 R3:water/up:p-basil ×5 · R5 lawn.overseed.autumn/ar:a-lawn ×2
2026-09  R3 R3:water/up:p-basil ×5 · R3 R3:mow/ar:a-lawn ×4 · R5 lawn.fertilize.autumn/ar:a-lawn ×3 · R5 lawn.aerate/ar:a-lawn ×2 · R5 lawn.overseed.autumn/ar:a-lawn ×2 · R5 lawn.scarify.autumn/ar:a-lawn ×2 · R2 R2:scarify/ar:a-lawn ×1
2026-10  R3 R3:mow/ar:a-lawn ×5 · R3 R3:water/up:p-basil ×5 · R5 lawn.aerate/ar:a-lawn ×1 · R5 lawn.fertilize.autumn/ar:a-lawn ×1
2026-11  R3 R3:water/up:p-basil ×5 · R3 R3:mow/ar:a-lawn ×3
2026-12  R3 R3:water/up:p-basil ×5

## Na leto, po straži (guard_key/subject)
  61× R3 R3:water/up:p-basil
  41× R3 R3:mow/ar:a-lawn
   4× R5 berries.fertilize/up:p-raspberry
   4× R5 fruit_tree.fertilize/up:p-apple
   4× R5 lawn.fertilize.autumn/ar:a-lawn
   4× R5 lawn.lawn_weed_moss.moss/ar:a-lawn
   4× R5 lawn.lawn_weed_moss.weed/ar:a-lawn
   4× R5 lawn.overseed.autumn/ar:a-lawn
   4× R5 vegetable.sow.direct/up:p-tomato
   3× R5 berries.treat.dormant/up:p-raspberry
   3× R5 lawn.aerate/ar:a-lawn
   3× R5 lawn.fertilize.spring/ar:a-lawn
   3× R5 lawn.overseed.spring/ar:a-lawn
   3× R5 lawn.scarify.spring/ar:a-lawn
   3× R5 vegetable.plant/up:p-tomato
   2× R5 lawn.scarify.autumn/ar:a-lawn
   2× R6 R6:sow/up:p-tomato
   1× R2 R2:fertilize/up:p-apple
   1× R2 R2:scarify/ar:a-lawn
   1× R5 lawn.roll/ar:a-lawn
   1× R5 tomato.harden_off/up:p-tomato`;
